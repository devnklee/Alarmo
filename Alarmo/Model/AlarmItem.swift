//
//  AlarmItem.swift
//  Alarmo
//
//  Created by kibeom lee on 2018. 2. 3..
//  Copyright © 2018년 kibeom lee. All rights reserved.
//

import Foundation
import RealmSwift

class AlarmItem : Object {
    
    @objc dynamic var address : String = ""
    @objc dynamic var lat : String = ""
    @objc dynamic var lon : String = ""
    @objc dynamic var time : String = ""
    @objc dynamic var repeatation : String = ""
    @objc dynamic var status : Bool = true
    
}
