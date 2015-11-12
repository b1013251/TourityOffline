/*

    各種センサ情報を取得できる

*/

import Foundation
import UIKit
import AVFoundation
import SpriteKit
import CoreLocation
import CoreMotion

class Sensor : NSObject , CLLocationManagerDelegate{
    
    
    // MARK: - 管理用メンバ
    let instance        : Sensor! = nil
    var gyroManager     : CMMotionManager! = nil
    var gyroHandler     : CMDeviceMotionHandler! = nil
    var locationManager : CLLocationManager! = nil
    var isRunning       : Bool = false
    
    
    // MARK : - 数値メンバ
    //var longitude   : Double = 0
    //var latitude    : Double = 0
    
    
    /*#####################################
        デバッグ用 位置情報を離さない
    #######################################*/
    let longitude :Double = 130.0
    let latitude  :Double = 40.0
    let  altitude : Double = 10.0
    
    var heading     : Double = 0
    var yaw         : Double = 0
    var roll        : Double = 0
    var pitch       : Double = 0
    
    // MARK: - シングルトン
    class var sharedInstance: Sensor {
        struct Static {
            static let instance : Sensor = Sensor()
        }
        return Static.instance
    }
    
    // MARK: - 初期化
    override private init() {
        super.init()
        
        locationManager = CLLocationManager()
        gyroManager     = CMMotionManager()
        isRunning = false
        
        //センサ
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        //位置情報
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 300
        
        //コンパス
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.headingOrientation = CLDeviceOrientation.LandscapeRight
        
        //回転角
        gyroManager.deviceMotionUpdateInterval = 0.1
        self.gyroHandler = { (data : CMDeviceMotion! , error : NSError!) -> () in
            if(!(error == nil)) {
                println(error)
            } else {
                self.yaw   = data.attitude.yaw
                self.roll  = data.attitude.roll
                self.pitch = data.attitude.pitch
            }
        }
    }
    
    //MARK: - 開始
    func start() {
        if !isRunning {
            isRunning = true
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            
            gyroManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: self.gyroHandler)
        }
    }
    
    //MARK: - 終了
    func stop() {
        if isRunning {
            isRunning = false
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
            gyroManager.stopDeviceMotionUpdates()
        }
    }
    
    //MARK: - 起動中？
    func status() -> Bool {
        return isRunning
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        self.heading = newHeading.trueHeading
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("location error... \(error.localizedDescription)")
    }
}