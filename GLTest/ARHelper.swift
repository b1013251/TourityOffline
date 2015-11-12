/*

ARに関する処理
　クラスメソッドしか作っていない

*/

import Foundation
import UIKit

class ARHelper {
    
    static let VIEW_ANGLE : Double  =  M_PI / 6.0 //30°
    static let NOT_EXIST  : Double  =  184
    static let EARTH_R    : Double  = 6371
    
    
    // パブリック関数
    class func isExist(#viewPOI : POI , posPOI : POI , heading : Double ) -> Double {
        
        let angle = getAngle(viewLat: viewPOI.latitude, viewLon: viewPOI.longitude
            , posLat: posPOI.latitude , posLon: posPOI.longitude)
        let trueHeading = degToRad(heading)
        var target_azimuth = trueHeading - angle
        
        
        if target_azimuth < VIEW_ANGLE && (-VIEW_ANGLE) < target_azimuth {
            //println(" exist \( radToDeg(target_azimuth) )")
            println(target_azimuth)
            return radToDeg(getRegularRad(target_azimuth))
        } else {
            //println("")
            return NOT_EXIST
        }
    }
    
    class func getVerticalAngle(#viewPOI : POI , posPOI : POI) -> Double {
        let radialDistance = sqrt(
            pow( viewPOI.altitude - posPOI.altitude , 2 ) +
                pow( self.getDistance(viewLat: viewPOI.latitude, viewLon: viewPOI.longitude, posLat: posPOI.latitude, posLon: posPOI.longitude) , 2)
        )
        var angle  = sin(  Double.abs(viewPOI.altitude - posPOI.altitude) / radialDistance )
        
        if( viewPOI.altitude > posPOI.altitude ) {
            angle = -angle
        }
        
        return angle
    }
    
    class func getRegularRad(rad :Double) -> Double {
        if rad < M_PI {
            return rad
        } else {
            return rad - 2 * M_PI
        }
    }
    
    
    
    // プライベート関数
    class private func getAngle(#viewLat : Double , viewLon : Double , posLat : Double , posLon : Double) -> Double {
        
        let lonDiff = degToRad(posLon - viewLon)
        let latDiff = degToRad(posLat - viewLat)
        let azimuth = (M_PI * 0.5) - atan(latDiff / lonDiff)
        
        if lonDiff > 0 {
            
            return azimuth
        } else if lonDiff < 0 {
            return azimuth + M_PI
        } else if latDiff < 0 { //lon == 0 で上むきなら180
            return M_PI
        }
        
        return 0.0
    }
    
    class private func getDistance(#viewLat : Double , viewLon : Double , posLat : Double , posLon : Double) -> Double {
        let distance = EARTH_R * acos( sin(viewLat) * sin(posLat) + cos(viewLat) * cos(posLat) * cos(viewLat - posLat) )
        //println("distance : \(distance)")
        return distance
    }
    
    class private func getVector(#viewLat : Double , viewLon : Double , posLat : Double , posLon : Double) -> (dx : Double , dy : Double) {
        let theta      : Double = degToRad(viewLon)
        let deltaTheta : Double = degToRad(posLon - viewLon)
        let deltaPhi   : Double = degToRad(posLat - viewLat)
        
        let dx         : Double = deltaPhi * cos(theta)
        let dy         : Double = deltaTheta
        
        //print("vector dy:\(dy) , dx:\(dx) ")
        
        return (dx : dx , dy : dy)
    }
    
    class func degToRad(degree : Double) -> Double {
        return degree * M_PI / 180.0
    }
    
    class func radToDeg(radian : Double) -> Double {
        return radian * 180.0 / M_PI
    }
    
    class private func diffAngle(rad1 : Double , rad2 : Double) -> Double {
        return  ( rad2 - rad1 )
    }
    
    
}