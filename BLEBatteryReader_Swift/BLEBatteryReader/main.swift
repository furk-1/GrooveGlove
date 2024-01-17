import CoreBluetooth
import Foundation

class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var targetPeripheral: CBPeripheral?
    var batteryLevelCharacteristic: CBCharacteristic?
    var notiThresholdCharacteristic: CBCharacteristic?
    var notiThreshold: Int?

    // Unique UUID (Universal Unique ID)
    let targetDeviceUUID = UUID(uuidString: "D9EE8F6F-4F03-8BDA-7990-8B978C4F7C75")!
    // let targetDeviceUUID = UUID(uuidString: "E535FAB6-9A47-D830-65FC-5C148F051E68")!

    let batteryServiceUUID = CBUUID(string: "180F")
    let batteryLevelCharacteristicUUID = CBUUID(string: "2A19")
    
    let notiThresholdServiceUUID = CBUUID(string: "AD58")  // Replace with your custom service UUID
    let notiThresholdCharacteristicUUID = CBUUID(string: "FE31")


    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                    self?.readNotiThresholdFromFile()
                }
        // Reads number for notification threshold every 5 seconds
    }
 
    
    /*
     Error handling - check to make sure Bluetooth port on PC system is ready to connect
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [batteryServiceUUID], options: nil)
        } else {
            print("Bluetooth is not powered on")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.identifier == targetDeviceUUID {
            targetPeripheral = peripheral
            targetPeripheral!.delegate = self
            centralManager.stopScan()
            centralManager.connect(targetPeripheral!, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        peripheral.discoverServices([batteryServiceUUID, notiThresholdServiceUUID])
    }   // Initial connection to device

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
            //Scanning through the services that the Bluetooth module offers
        if let services = peripheral.services {
            for service in services  {      //Battery service UUID - not a custom service, but universal for battery service
                if service.uuid == batteryServiceUUID {
                    //Looks for the specific UUID of the battery characteristic
                            peripheral.discoverCharacteristics([batteryLevelCharacteristicUUID], for: service)
                    //Noti threshold service - custom servicde also a part of CircuitPython bluetooth advertisement, works the same way as battery characteristic but not custom
                        } else if service.uuid == notiThresholdServiceUUID {
                            peripheral.discoverCharacteristics([notiThresholdCharacteristicUUID], for: service)
                        }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error { //ERROR HANDLING - has a service but can't find characteristic
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
				
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == batteryLevelCharacteristicUUID {
                    batteryLevelCharacteristic = characteristic
                    // Start reading the battery level every 5 seconds
                    Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                        self?.targetPeripheral?.readValue(for: characteristic)
                    }
                }
                // Stores characteristic values in memory
                else if characteristic.uuid == notiThresholdCharacteristicUUID{
                    // Write to BLE characteristic
                    notiThresholdCharacteristic = characteristic
                    
                }
            }
        }
    }
    
    func readNotiThresholdFromFile() {
        let fileURL = URL(fileURLWithPath: "/Users/furquaansyed/Desktop/Senior Design/DesktopInterface/selected_battery_threshold.txt")
//File that is acting as a buffer for notification threshold
        do {
            let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
            if let number = Int(fileContents.trimmingCharacters(in: .whitespacesAndNewlines)) {
                notiThreshold = number
                print("Read number: \(number)")
                if let characteristic = notiThresholdCharacteristic {
                            var data = Data([UInt8(number)])  // Assuming the value fits in one byte (0-255)
                            targetPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
                    // Writes back to threshold characteristic - BLE on Circuitpython picks it up
                        }
                            } else {
                                print("Failed to convert file contents to number")
                            }
        } catch {
            print("can't read this file")
        } // Error handling
    }
        

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error reading characteristics: \(error.localizedDescription)")
            return
        }

        if characteristic.uuid == batteryLevelCharacteristicUUID, let value = characteristic.value {
            let batteryLevel = value.first.map { Int($0) }
            // Takes battery level of the system it is reading from the characteristic and
            let fileURL = URL(fileURLWithPath: "/Users/furquaansyed/Desktop/Senior Design/DesktopInterface/BatteryLevelll.txt")
            do {
                try "\(batteryLevel ?? 0)".write(to: fileURL, atomically: true, encoding: .utf8)
                print("\(batteryLevel ?? 0)")
            } catch {
                print("Failed to write battery level to file: \(error)")
            }
        }
    }
}

let bleManager = BLEManager()
RunLoop.main.run()


//
//
//class BluetoothScanner: NSObject, CBCentralManagerDelegate {
//    private var centralManager: CBCentralManager!
//
//    override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//    }
//
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn {
//            print("Bluetooth is On. Starting scan...")
//            centralManager.scanForPeripherals(withServices: nil, options: nil)
//        } else {
//            print("Bluetooth is not available.")
//        }
//    }
//
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        let deviceName = peripheral.name ?? "Unknown"
//        let deviceUUID = peripheral.identifier
//        print("Discovered \(deviceName), UUID: \(deviceUUID)")
//    }
//
//    // Implement other delegate methods if necessary
//}
//
//// Global instance
//let scanner = BluetoothScanner()
//
//// Start the run loop
//RunLoop.main.run()
//
//
