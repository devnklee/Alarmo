//
//  AlarmDetailController.swift
//  Alarmo
//
//  Created by kibeom lee on 2018. 2. 3..
//  Copyright © 2018년 kibeom lee. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

class AlarmDetailController : UIViewController {
    
    
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timePicker: UIDatePicker!
    var lat : String = ""
    var lon : String = ""
    var isAddressSet = false
    
    let days : [String] = ["월", "화", "수", "목", "금", "토", "일"]
    var selected : [Bool] = [false,false,false,false,false,false,false]
    
    let dateFormatter = DateFormatter()
    
    let realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "HH:mm"
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    @IBAction func addressButtonClicked(_ sender: UIButton) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Get Address", message: "", preferredStyle: .alert)
        
        let getAddressAction = UIAlertAction(title: "Next", style: .default) { (action) in
            if textField.text != "" {
                self.selectAddress(with: textField.text!)
            }else {
                self.addressButtonClicked(self.addressButton)
            }
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .default, handler: nil)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Type your Address"
            textField = alertTextField
        }
        
        alert.addAction(getAddressAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    func selectAddress(with address: String) {
        let googleGeoCodingURL : String = "https://maps.googleapis.com/maps/api/geocode/json"
        let googleAPIKEY : String = "AIzaSyCgI-oP2cyA954bobrb_3-Cm3-X9Qx4ZeA"
        let param : [String : String] = ["sensor" : "false",
                                         "language" : "ko",
                                         "address" : address,
                                         "key" : googleAPIKEY]
        var addressList : [AddressItem] = [AddressItem]()
        
        Alamofire.request(googleGeoCodingURL, method: .get, parameters: param).responseJSON { (response) in
            if response.result.isSuccess {
                let data : JSON = JSON(response.result.value!)
                if data["status"] == "OK" {
                    //print(data)
                    print(data["results"].count)
                    
                    for i in 0..<data["results"].count {
                        let item = AddressItem()
                        item.address = data["results"][i]["formatted_address"].stringValue
                        item.lat = data["results"][i]["geometry"]["location"]["lat"].stringValue
                        item.lon = data["results"][i]["geometry"]["location"]["lng"].stringValue
                        addressList.append(item)
                    }
                }
                
                self.chooseAddress(with: addressList)
                
                
            }else {
                print(response.result.error!)
            }
            
        }
        
    }
    
    func chooseAddress(with addressList: [AddressItem]) {
        let alert = UIAlertController(title: "choose address", message: "", preferredStyle: .alert)
        for i in 0..<addressList.count {
            let action = UIAlertAction(title: addressList[i].address, style: .default, handler: { (alertaction) in
                self.addressButton.setTitle(addressList[i].address, for: .normal)
                self.lat = addressList[i].lat
                self.lon = addressList[i].lon
                self.isAddressSet = true
            })
            alert.addAction(action)
        }

        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func saveAlarm(_ sender: UIButton) {
        if isAddressSet {
        let strDate = dateFormatter.string(from: timePicker.date)
        do {
            try realm.write {
                let newAlarm = AlarmItem()
                
                newAlarm.address = (addressButton.titleLabel?.text)!
                newAlarm.lat = self.lat
                newAlarm.lon = self.lon
                newAlarm.time = strDate
                
                var str = ""
                for (day, repeats) in zip(days, selected) {
                    if repeats {
                        str = str + day
                    }
                }
                newAlarm.repeatation = str
                
                
                realm.add(newAlarm)
                
                navigationController?.viewControllers[0].viewWillAppear(true)
                navigationController?.popToRootViewController(animated: true)
            }
        }
        catch {
            print("error adding item")
        }
        
        }else {
            print("choose address first")
        }
    }
}


//MARK: - collection View

extension AlarmDetailController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        cell.label.text = days[indexPath.row]
        if selected[indexPath.row] == false {
            cell.contentView.backgroundColor = UIColor.white
        }else {
            cell.contentView.backgroundColor = UIColor.blue
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selected[indexPath.row] = !selected[indexPath.row]
        collectionView.reloadData()
    }
}
