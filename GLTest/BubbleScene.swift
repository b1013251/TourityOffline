/*

    
    SpriteKitのAR表示用 Scene


*/

import Foundation
import SpriteKit
import CoreLocation


class BubbleScene : SKScene , SKPhysicsContactDelegate, SocketDelegate  {
    
    /*#############################################
        デバッグ用　固定されたバブル
    ###################START######################*/
    
    let bubbles : [POI] = [
        POI(post_id: 0, latitude: 40.0001, longitude: 129.9999, altitude: 3.0, message: "楽しい", file_path: "tmp/sample.jpg", posted_time: "debug"),
        POI(post_id: 0, latitude: 40.0003, longitude: 130.0310, altitude: 10.0, message: "やああああ", file_path: "tmp/sample.jpg", posted_time: "debug"),
        POI(post_id: 0, latitude: 40.0035, longitude: 129.9989, altitude: 5.0, message: "とてもきれい", file_path: "tmp/sample.jpg", posted_time: "debug"),
        POI(post_id: 0, latitude: 39.9999, longitude: 129.9399, altitude: 8.0, message: "アカデミックリンク", file_path: "tmp/sample.jpg", posted_time: "debug"),
        POI(post_id: 0, latitude: 39.998, longitude: 130.0002, altitude: 18.0, message: "はこだて", file_path: "tmp/sample.jpg", posted_time: "debug")
        //POI(post_id: 0, latitude: 40.002, longitude: 130.0000, altitude: 18.0, message: "未来大学", file_path: "tmp/sample.jpg", posted_time: "debug")
    ]
    
    
    /*-------------------END---------------------*/
    
    var sensor : Sensor!
    var socket : Socket!
    var detailDelegate : DetailDelegate!
    
    var bubbleImage : [BubbleSprite] = [] //バブルを格納
    var posPOI      : [POI]          = [] //バブル毎の位置情報を格納
    
    
    override func didMoveToView(view: SKView) {
        //データの取得
        self.sensor = Sensor.sharedInstance
        self.sensor.start()
        
        //シーンが表示されるたびにSocketサーバに接続
        /*
        self.socket = Socket.sharedInstance
        self.socket.delegate = self
        self.socket.clearBubble()
        self.socket.connect()
        */
        
        //バブルをローカルで自動生成
        for bubble in bubbles {
            self.createBubble(bubble)
        }
        
        
        //画面関係の初期化
        self.backgroundColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        self.size.height = view.bounds.height
        self.size.width  = view.bounds.width
        self.physicsWorld.gravity = CGVectorMake(0,0)
    }
    
    override func update(currentTime: CFTimeInterval) {
        let realHeading : Double = fmod(sensor.heading - ARHelper.radToDeg(sensor.pitch) + 360.0 , 360.0)
        //println(realHeading)
        let viewPOI = POI(
            post_id  : 0 , //自分の位置情報にIDはないので，適当な値を入れる
            latitude : sensor.latitude,
            longitude: sensor.longitude ,
            altitude : sensor.altitude ,
            file_path : "")
        
        /* 向いている方向を補正とか言ってみるテスト
        println("補正前 \(sensor.heading)")
        println("ピッチ \(ARHelper.radToDeg(sensor.pitch))")
        println("補正後 \(realHeading)" )
        */
        
        //println("\(sensor.pitch) \(sensor.yaw) \(sensor.roll) \(sensor.heading)")
        
        for ( var i = 0 ; i < posPOI.count ; i++ ) {
            let place : Double = ( ARHelper.isExist(viewPOI: viewPOI, posPOI: posPOI[i] , heading: realHeading) )
            
            if place != ARHelper.NOT_EXIST { //存在していれば
                //println(place)
                let horizontal : Double = (-1.0) * Double(place / 60.0) * Double(self.size.width)
                
                let x = Double(CGRectGetMidX(self.frame)) + cos( sensor.pitch ) * horizontal
                let y = Double(CGRectGetMidY(self.frame)) + sin( sensor.pitch ) * horizontal
                    + Double( ARHelper.radToDeg(sensor.roll + M_PI_2) * 10.0)
                    + Double( ARHelper.getVerticalAngle(viewPOI: viewPOI , posPOI: posPOI[i]) * Double(CGRectGetMidY(self.frame)))
                
                let location = CGPoint(x: x, y: y)
                
                let rotateAction  =  SKAction.rotateToAngle(CGFloat(sensor.pitch), duration: NSTimeInterval(0.0))
                let moveAction    =  SKAction.moveTo(location , duration: NSTimeInterval(0))
                //let fadeInAction  =  SKAction.fadeInWithDuration(0.2)
                
                //bubbleImage[i].hidden = true
                bubbleImage[i].runAction(rotateAction)
                bubbleImage[i].runAction(moveAction)
                
                //移動すべき範囲内にあれば表示
                /*
                let xrange : Bool = ( Double(bubbleImage[i].position.x) < x + 100.0 ) && ( x - 100.0 < Double(bubbleImage[i].position.x) )
                let yrange : Bool = ( Double(bubbleImage[i].position.y) < y + 100.0 ) && ( y - 100.0 < Double(bubbleImage[i].position.y) )
                if xrange && yrange {
                    self.bubbleImage[i].hidden = false
                }
                */
                bubbleImage[i].hidden = false
                
            } else {
                bubbleImage[i].hidden = true
            }
        }
        
    }
    
    //MARK: - Socket Delegateの実装
    func createBubble(poi : POI)  {
        println("bubble created : \(poi.message)")
        //バブル画像部分
        let node : BubbleSprite! = BubbleSprite(imageNamed: "bubble.png")
        node.xScale   *= 0.5
        node.yScale   *= 0.5
        //node.position = CGPointMake(self.size.width / 2 , self.size.height / 2 )
        //node.alpha    = 0.0
        node.hidden = true
        node.userInteractionEnabled = true
        node.name     = poi.message
        node.poi      = poi
        node.detailDelegate = self.detailDelegate
        
        //node.rand     = Int(arc4random() % 100 ) - 49
        
        
        
        //文字部分
        let label : SKLabelNode = SKLabelNode(fontNamed:"HiraKakuProN-W3")
        label.fontSize  =  40
        label.position  =  CGPointMake( 0 , 0 )
        label.alpha     =  1.0
        label.zPosition =  label.zPosition + 1
        
        //6文字以上を...に変換
        if count(poi.message) > 6 {
            var idx: String.Index
            idx = advance(poi.message.startIndex,6)
            
            label.text = poi.message.substringToIndex(idx) + "..."
        } else {
            label.text = poi.message
        }
        
        //衝突時に位置をランダムで移動
        //self.physicsWorld.contactDelegate = self
       // node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width)
       // node.physicsBody?.categoryBitMask = 0x1
       // node.physicsBody?.collisionBitMask = 0x1 << 1
       // node.physicsBody?.contactTestBitMask = 0x1 | 0x1 << 1
        
        //シーンにバブルを追加する
        node.addChild(label)
        self.addChild(node)
        
        
        //当たり判定をつけることにより重ならないようにする
        //node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(node.size.width , node.size.height ))
        
        
        posPOI.append(poi)
        bubbleImage.append(node)
    }

    func didBeginContact(contact: SKPhysicsContact) {
        println("衝突! ---- !!!")
        println(contact.bodyA.node?.name)
        println(contact.bodyB.node?.name)
            //(contact.bodyA.node as! BubbleSprite).poi.latitude  +=  0.0001 * Double(Int(arc4random() % 4) - 2)
        //(contact.bodyA.node as! BubbleSprite).poi.longitude +=  0.001 * Double(Int(arc4random() % 4) - 2)
        //contact.bodyA.node?.alpha = 0.0
        //contact.bodyB.node?.alpha = 1.0
        //contact.bodyA.node?.removeFromParent()
        //contact.bodyA.node?.alpha = 0.0
        //contact.bodyB.node?.alpha = 1.0
    }
}



protocol SocketDelegate {
    func createBubble(poi : POI)
}