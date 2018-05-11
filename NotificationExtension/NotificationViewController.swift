//
//  NotificationViewController.swift
//  NotificationExtension
//
//  Created by kibeom lee on 2018. 2. 16..
//  Copyright © 2018년 kibeom lee. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import RealmSwift
import Alamofire
import SwiftyJSON

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var weatherTemp: UILabel!
    @IBOutlet weak var weatherMaxMin: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherCondition: UILabel!
    
    @IBOutlet weak var day1: UILabel!
    @IBOutlet weak var day1Image: UIImageView!
    @IBOutlet weak var day1Temp: UILabel!
    @IBOutlet weak var day1Condition: UILabel!
    
    @IBOutlet weak var day2: UILabel!
    @IBOutlet weak var day2Temp: UILabel!
    @IBOutlet weak var day2Image: UIImageView!
    @IBOutlet weak var day2Condition: UILabel!
    
    @IBOutlet weak var day3: UILabel!
    @IBOutlet weak var day3Temp: UILabel!
    @IBOutlet weak var day3Image: UIImageView!
    @IBOutlet weak var day3Condition: UILabel!
    
    @IBOutlet weak var day4: UILabel!
    @IBOutlet weak var day4Temp: UILabel!
    @IBOutlet weak var day4Image: UIImageView!
    @IBOutlet weak var day4Condition: UILabel!
    
    @IBOutlet weak var day5: UILabel!
    @IBOutlet weak var day5Temp: UILabel!
    @IBOutlet weak var day5Image: UIImageView!
    @IBOutlet weak var day5Condition: UILabel!
    
    @IBOutlet weak var pm25: UILabel!
    @IBOutlet weak var pm10: UILabel!
    @IBOutlet weak var no2: UILabel!
    @IBOutlet weak var so2: UILabel!
    @IBOutlet weak var o3: UILabel!
    @IBOutlet weak var co: UILabel!
    
    
    let WEATHER_URL = "https://query.yahooapis.com/v1/public/yql"
    let DUST_URL = "http://api.waqi.info/feed/geo:"
    let DUST_API_KEY = "5a72da1f5ba5ac5031118d7371b8e6b3ac2566d3"
    
    //setting Realm database
    let fileURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.io.realm.app_group")!
        .appendingPathComponent("default.realm")
    lazy var config = {
        return Realm.Configuration(fileURL: fileURL)}()
    lazy var realm = {
        return try! Realm(configuration: config)}()
    var alarmList : Results<AlarmItem>?
    
    
    let weatherModel = WeatherModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alarmList = realm.objects(AlarmItem.self)
        // Do any required interface initialization here.
        
        //let size = view.bounds.size
        //preferredContentSize = CGSize(width: size.width, height: size.height)
        
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        // self.label?.text = notification.request.content.body
        if let item = (alarmList?.filter("address CONTAINS[cd] %@", content.title))?.first {
            
            let lat = item.lat
            let lon = item.lon
            let q = "select * from weather.forecast where woeid in (SELECT woeid FROM geo.places WHERE text=\"(\(lat),\(lon))\") and u=\"c\""
            let params : [String : String] = ["q" : q , "format" : "json"]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
            
            
            getDustData(url: "\(DUST_URL)\(lat);\(lon)/", parameters: ["token" : DUST_API_KEY])
            
        }
        
        
    }
    func getDustData(url: String, parameters: [String: String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                let dustJSON : JSON = JSON(response.result.value!)
                
                if let pm25 = dustJSON["data"]["iaqi"]["pm25"]["v"].stringValue as String?{
                    self.weatherModel.pm25 = pm25
                    self.weatherModel.pm10 = dustJSON["data"]["iaqi"]["pm10"]["v"].stringValue
                    self.weatherModel.no2 = dustJSON["data"]["iaqi"]["no2"]["v"].stringValue
                    self.weatherModel.so2 = dustJSON["data"]["iaqi"]["so2"]["v"].stringValue
                    self.weatherModel.o3 = dustJSON["data"]["iaqi"]["o3"]["v"].stringValue
                    self.weatherModel.co = dustJSON["data"]["iaqi"]["co"]["v"].stringValue
                    
                    self.updateContentWithDustData()
                }
            }
        }
    }
    
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                let weatherJSON : JSON = JSON(response.result.value!)
                
                
                if let temp = weatherJSON["query"]["results"]["channel"]["item"]["condition"]["temp"].stringValue as String? {
                    self.weatherModel.temperature = temp
                    self.weatherModel.tempMax = weatherJSON["query"]["results"]["channel"]["item"]["forecast"][0]["high"].stringValue
                    self.weatherModel.tempMin =  weatherJSON["query"]["results"]["channel"]["item"]["forecast"][0]["low"].stringValue
                    self.weatherModel.condition = weatherJSON["query"]["results"]["channel"]["item"]["condition"]["text"].stringValue
                    self.weatherModel.tempCode = weatherJSON["query"]["results"]["channel"]["item"]["condition"]["code"].intValue
                    
                    for i in 0...4 {
                        let forecast = WeatherForecast()
                        forecast.day = weatherJSON["query"]["results"]["channel"]["item"]["forecast"][i]["day"].stringValue
                        forecast.tempLow = weatherJSON["query"]["results"]["channel"]["item"]["forecast"][i]["low"].stringValue
                        forecast.tempHigh = weatherJSON["query"]["results"]["channel"]["item"]["forecast"][i]["high"].stringValue
                        forecast.code = weatherJSON["query"]["results"]["channel"]["item"]["forecast"][i]["code"].intValue
                        forecast.condition = weatherJSON["query"]["results"]["channel"]["item"]["forecast"][i]["text"].stringValue
                        self.weatherModel.forecast.append(forecast)
                        
                    }
                    
                    self.updateContentWithWeatherData()
                }
                
            }else {
                self.weatherTemp.text = "Weather Unavailable"
            }
        }
    }
    
    
    
    func updateContentWithWeatherData() {
        
        let image = weatherModel.updateWeatherIcon(condition: weatherModel.tempCode)
        
        weatherIcon.image = UIImage(named: image)
        weatherTemp.text = "\(weatherModel.temperature)°"
        weatherMaxMin.text = "↓ \(weatherModel.tempMin)° ↑ \(weatherModel.tempMax)°"
        weatherCondition.text = weatherModel.condition
        
        //day1.text = weatherModel.forecast[0].day
        day2.text = weatherModel.forecast[1].day
        day3.text = weatherModel.forecast[2].day
        day4.text = weatherModel.forecast[3].day
        day5.text = weatherModel.forecast[4].day
        
        day1Temp.text = "↓ \(weatherModel.forecast[0].tempLow)° ↑ \(weatherModel.forecast[0].tempHigh)°"
        day2Temp.text = "↓ \(weatherModel.forecast[1].tempLow)° ↑ \(weatherModel.forecast[1].tempHigh)°"
        day3Temp.text = "↓ \(weatherModel.forecast[2].tempLow)° ↑ \(weatherModel.forecast[2].tempHigh)°"
        day4Temp.text = "↓ \(weatherModel.forecast[3].tempLow)° ↑ \(weatherModel.forecast[3].tempHigh)°"
        day5Temp.text = "↓ \(weatherModel.forecast[4].tempLow)° ↑ \(weatherModel.forecast[4].tempHigh)°"
        
        day1Condition.text = weatherModel.forecast[0].condition
        day2Condition.text = weatherModel.forecast[1].condition
        day3Condition.text = weatherModel.forecast[2].condition
        day4Condition.text = weatherModel.forecast[3].condition
        day5Condition.text = weatherModel.forecast[4].condition
        
        day1Image.image = UIImage(named: weatherModel.updateWeatherIcon(condition: weatherModel.forecast[0].code))
        day2Image.image = UIImage(named: weatherModel.updateWeatherIcon(condition: weatherModel.forecast[1].code))
        day3Image.image = UIImage(named: weatherModel.updateWeatherIcon(condition: weatherModel.forecast[2].code))
        day4Image.image = UIImage(named: weatherModel.updateWeatherIcon(condition: weatherModel.forecast[3].code))
        day5Image.image = UIImage(named: weatherModel.updateWeatherIcon(condition: weatherModel.forecast[4].code))
    }
    
    func updateContentWithDustData() {
        pm25.text = "pm25: \(weatherModel.pm25)"
        pm10.text = "pm10: \(weatherModel.pm10)"
        no2.text = "no2: \(weatherModel.no2)"
        so2.text = "so2: \(weatherModel.so2)"
        o3.text = "o3: \(weatherModel.o3)"
        co.text = "co: \(weatherModel.co)"
    }
    
    
    
}
