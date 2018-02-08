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

class AlarmViewController: UITableViewController {

    let realm = try! Realm()
    var alarmList : Results<AlarmItem>?
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        loadData()
        tableView.rowHeight = 80
        
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound]) { (grant, error) in
//            if grant {
//                print("notification granted")
//            }else {
//                print("notification denined")
//            }
//        }
//        
//        let content = UNMutableNotificationContent()
//        content.title = "this is title"
//        content.body = "this is body"
//        content.sound = UNNotificationSound.default()
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
//        
//        let identifier = "LocalNotification"
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//        center.add(request) { (error) in
//            if error != nil {
//                print("something went wrong")
//            }else {
//                print("request added")
//            }
//        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
  
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as! AlarmCell
        
        cell.alarmTime.text = alarmList![indexPath.row].time
        cell.alarmAddress.text = alarmList?[indexPath.row].address
        return cell
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
        tableView.reloadData()
    }
    

    
}

