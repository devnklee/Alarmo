//
//  WeatherModel.swift
//  Alarmo
//
//  Created by kibeom lee on 2018. 2. 26..
//  Copyright © 2018년 kibeom lee. All rights reserved.
//

import Foundation

class WeatherModel {
    //Declare your model variables here
    var temperature: String = ""
    var condition: String = ""
    var tempMin: String = ""
    var tempMax: String = ""
    var tempCode : Int = 0
    var weatherIconName: String = ""
    var forecast = [WeatherForecast]()
    //dust variables
    var o3 : String = ""
    var so2 : String = ""
    var pm25 : String = ""
    var pm10 : String = ""
    var no2 : String = ""
    var co : String = ""

    
    //This method turns a condition code into the name of the weather condition image
    
    func updateWeatherIcon(condition: Int) -> String {

        
        switch (condition) {
            
        case 0...4, 45 :
            return "tstorm3"
            
        case 5...9 :
            return "light_rain"
            
        case 10...12, 35, 40 :
            return "shower3"
            
        case 13...17 :
            return "snow4"
            
        case 18...25 :
            return "fog"
            
        case 26 :
            return "overcast"
            
        case 27...31, 33...34, 44 :
            return "cloudy2"
            
        case 32, 36 :
            return "sunny"
            
        case 37...39 , 47:
            return "tstorm1"
            
        case 40...43 , 46 :
            return "snow5"
            
        default :
            return "dunno"
        }
        
    }
}
