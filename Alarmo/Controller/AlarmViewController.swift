//
//  AlarmViewController.swift
//  Alarmo
//
//  Created by kibeom lee on 2018. 2. 3..
//  Copyright © 2018년 kibeom lee. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import Alamofire
import SwiftyJSON

class AlarmViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    
    
    let WEATHER_URL = "https://query.yahooapis.com/v1/public/yql"
    let DUST_URL = "http://api.waqi.info/feed/geo:"
    let DUST_API_KEY = "5a72da1f5ba5ac5031118d7371b8e6b3ac2566d3"
    
    let fileURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.io.realm.app_group")!
        .appendingPathComponent("default.realm")
    lazy var config = {
        return Realm.Configuration(fileURL: fileURL)}()
    lazy var realm = {
        return try! Realm(configuration: config)}()
    
    var alarmList : Results<AlarmItem>?
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        loadData()
        tableView.rowHeight = 80
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    func updatingLocalAlarm(at address: String, within time:String, status: Bool) {
        
        let center = UNUserNotificationCenter.current()
        if status {
            center.getNotificationSettings { (settings) in
                if settings.authorizationStatus == .authorized {
                    print("authorized, let's begin")
                    
                    
                    let content = UNMutableNotificationContent()
                    content.title = "\(address)"
                    content.body = "weather will be shonw later"
                    content.sound = UNNotificationSound.default()
                    content.categoryIdentifier = "Alarmo"
                    
                    
                    var dateComponents = DateComponents()
                    let times = time.split(separator: ":")
                    dateComponents.hour = Int(times[0])
                    dateComponents.minute = Int(times[1])
                    
                    
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    
                    let request = UNNotificationRequest(identifier: "\(address)-\(time)", content: content, trigger: trigger)
                    
                    center.add(request, withCompletionHandler: { (error) in
                        if error != nil {
                            print("error adding request")
                        }
                    })
                    
                    center.getPendingNotificationRequests(completionHandler: { (request) in
                        if !request.isEmpty {
                            print(request.count)
                            for r in request {
                                
                                print(r.identifier )
                            }
                        }
                    })
                }
                
            }
        }else{
            center.removePendingNotificationRequests(withIdentifiers: ["\(address)-\(time)"])
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: 
            indexPath) as! AlarmCell
        cell.alarmSwitch.tag = indexPath.row
        cell.alarmSwitch.addTarget(self, action: #selector(self.SwitchAction(_:)), for: .touchUpInside)
        
        let address = alarmList![indexPath.row].address
        let time = alarmList![indexPath.row].time
        let status = alarmList![indexPath.row].status
        
        cell.alarmTime.text = time
        cell.alarmAddress.text = address
        cell.alarmSwitch.setOn(status, animated: true)
        
        updatingLocalAlarm(at: address, within: time, status: status)
        
        return cell
    }
    
    @objc func SwitchAction(_ sender: UISwitch){
        //set function for switch button that is in tableview cell
        print(sender.tag)
        do{
            try realm.write {
                alarmList![sender.tag].status = !alarmList![sender.tag].status
            }
        }catch{
            
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmList!.count
        
    }
    
    //MARK: - Deleting tableview Cells
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            if let cellForDelete = alarmList?[indexPath.row] {
                do {
                    try realm.write {
                        //remove local notification first then realm object
                        updatingLocalAlarm(at: cellForDelete.address, within: cellForDelete.time, status: false)
                        realm.delete(cellForDelete)
                    }
                }catch {
                    print("Error deleting cell")
                }
            }
        }
        tableView.reloadData()
    }
    
    func loadData() {
        alarmList = realm.objects(AlarmItem.self)
        print(realm.configuration.fileURL!)
        tableView.reloadData()
    }
    
    @IBAction func addalert(_ sender: UIBarButtonItem) {
        let content = UNMutableNotificationContent()
        content.title = "대한민국 서울특별시 마포구 아현동"
        content.body = "Testing notification"
        content.categoryIdentifier = "Alarmo"
        

        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            //print(error as Any)
        }
        
        
        if let item = alarmList?.first {
            
            //testing weather api
            let lat = item.lat
            let lon = item.lon
            let q = "select * from weather.forecast where woeid in (SELECT woeid FROM geo.places WHERE text=\"(\(lat),\(lon))\") and u=\"c\""
            let params : [String : String] = ["q" : q , "format" : "json"]
            
           getWeatherData(url: WEATHER_URL, parameters: params)
            
            //testing dust api
//            let url = "\(DUST_URL)\(lat);\(lon)/"
//            let param2 : [String : String] = ["token" : DUST_API_KEY]
//            getWeatherData(url: url, parameters: param2)
        }
        
    }
    
    
    func getWeatherData(url: String, parameters: [String: String]) {
        print(url)
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
              //  print(weatherJSON)
                
                
                if let temp = weatherJSON["query"]["results"]["channel"]["item"]["condition"]["temp"].stringValue as String? {
                    print(temp)
                    print(weatherJSON["query"]["results"]["channel"]["item"]["forecast"][0]["high"].stringValue)
                    print(weatherJSON["query"]["results"]["channel"]["item"]["forecast"][0]["low"].stringValue)
                    print(weatherJSON["query"]["results"]["channel"]["item"]["condition"]["text"].stringValue)
                    print(weatherJSON["query"]["results"]["channel"]["item"]["condition"]["code"].intValue)

                    for i in 0...4 {
                        print("-----\(i)-----")
                        print(weatherJSON["query"]["results"]["channel"]["item"]["forecast"][i]["day"].stringValue)
                        print(weatherJSON["query"]["results"]["channel"]["item"]["forecast"][i]["low"].stringValue)
                        print(weatherJSON["query"]["results"]["channel"]["item"]["forecast"][i]["high"].stringValue)
                        print(weatherJSON["query"]["results"]["channel"]["item"]["forecast"][i]["code"].intValue)
                        print(weatherJSON["query"]["results"]["channel"]["item"]["forecast"][i]["text"].stringValue)
                        

                    }
                    
                }
            }
        }
        
    }
    
    
    
    
    
}

