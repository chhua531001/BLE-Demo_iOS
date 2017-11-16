//
//  ViewController.swift
//  BLE Demo
//
//  Created by Nimblechapps iOS on 22/07/17.
//  Copyright © 2017 Nimblechapps iOS. All rights reserved.
//

import UIKit
import CoreBluetooth
class ViewController: UIViewController {
@IBOutlet var tableView : UITableView!
@IBOutlet var lblStatus : UILabel!
    
var centralManager: CBCentralManager?
var serviceUUIDs: [CBUUID]?
var mWriteCharacteristic: CBCharacteristic!
var mReadCharacteristic: CBCharacteristic!
var peripherals = Array<CBPeripheral>()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBluetooth()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupBluetooth(){
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// Extenstion to manage the Core Bluetooth Methods
extension ViewController : CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
            lblStatus.text = "Available Bluetooth Devices"
        }
        else {
            let alert = UIAlertController.init(title: "Bluetooth Not Switched On", message: "Switch on the bluetooth and try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                
            }));
            self.present(alert, animated: true, completion: { 
                
            })
            lblStatus.text = "Bluetooth not swictched on"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let manufactureData = advertisementData["kCBAdvDataManufacturerData"].debugDescription
        //讀出來的正確資料為 Optional(<5900468e 006e6873 2e686363 092e7477 2f>)
        //Using String extension
        //為了取出468e
        let uuid = manufactureData[14..<18]
        
//        debugPrint("Scan central --> \(central)")
//        debugPrint("Scan Result --> \(peripheral)")
//        debugPrint("Scan Service --> \(service)")
        debugPrint("Scan Result RSSI --> \(RSSI)")
        debugPrint("advertisementData --> \(manufactureData)")
        debugPrint("advertisementData count --> \(manufactureData.count)")
        debugPrint("uuid --> \(uuid)")
        
//        for service in peripheral.services! {
//
//            print("Discovered service: \(service.uuid)")
//        }
        
        if peripherals.contains(peripheral){
           tableView.reloadData()
        }
        else {
            if(uuid.isEqualToString(find: "468e")) {
                peripherals.append(peripheral)
                tableView.reloadData()
            }
        }
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager?.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        // If you know the UDID of specific service you can pass that here
        //peripheral.discoverServices([CBUUID(nsuuid: UUID(uuidString: "")!)])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
                for service in peripheral.services! {
        
                    print("Discovered service: \(service.uuid)")
                }

        
        
        let alert = UIAlertController(title: "Error", message: "There was error connecting to the device. Try again later", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

// Extenstion to manage the Peripheral Services
extension ViewController : CBPeripheralDelegate
{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //
        if (error == nil) {
            for service in peripheral.services! {
                
                print("Discovered service: \(service.uuid)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        else {
            let alert = UIAlertController(title: "Error", message: "There was error discovering Services", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //
        if (error == nil) {
            print(service.characteristics ?? "")
            
            for newChar: CBCharacteristic in service.characteristics!{
                
//                peripheral.setNotifyValue(true, for: newChar)
                
                let characteristicUUID = newChar.uuid.uuidString
                print("new Characteristic UUID--> \(characteristicUUID)")
                if(characteristicUUID == "468E6032-AA75-2215-88CA-F9CFBB2575D5") {
                    mWriteCharacteristic = newChar
                } else if(characteristicUUID == "468E6033-AA75-2215-88CA-F9CFBB2575D5") {
                    mReadCharacteristic = newChar
                    peripheral.setNotifyValue(true, for: newChar)
                }
            }

            print("Write Characteristic UUID--> \(mWriteCharacteristic.uuid.uuidString)")
            print("Read Characteristic UUID--> \(mReadCharacteristic.uuid.uuidString)")
            
//            var parameter = NSInteger(1)
//            let data = NSData(bytes: &parameter, length: 1)
            
//            let data = "0400".data(using: .utf8)
            let data = "0004".hexadecimal();
            peripheral.writeValue(data!, for: mWriteCharacteristic!, type: CBCharacteristicWriteType.withResponse)
//            peripheral.writeValue(data as Data, forCharacteristic: characteric, type: CBCharacteristicWriteType.WithResponse)
            
            
            
        }
        else {
            
            let alert = UIAlertController(title: "Error", message: "There was error discovering characteristics", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("Notification changed:\(characteristic)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        print("characteristic changed:\(characteristic)")
    }
    
}


// Extenstion to manage the UITableView
extension ViewController : UITableViewDataSource , UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell        
        let peripheral = peripherals[indexPath.row]
        if  peripheral.name == "" || peripheral.name == nil {
           cell.textLabel?.text = String(describing: peripheral.identifier)
        }
        else {
          cell.textLabel?.text = peripheral.name
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        centralManager?.connect(peripherals[indexPath.row], options: nil)
    }
}

//Swift 4 : If you want to use subscripts on Strings like "palindrome"[1..<3] and "palindrome"[1...3], use these extensions.
extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    //user define String Equal
    func isEqualToString(find: String) -> Bool {
        return String(format: self) == find
    }
    
    func hexadecimal() -> Data? {
        var data = Data(capacity: self.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else { return nil }
        
        print("data count = \(data.count)")
        
        return data
    }
}
