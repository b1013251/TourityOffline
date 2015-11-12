/*

    Socket.ioの接続を管理する

*/

import Foundation
import Socket_IO_Client_Swift
import SpriteKit


/* SocketIOでリアルタイムにバブルを受け取るためのクラス */
class Socket{
    
    var socket     : SocketIOClient!
    var bubblePool : [NSDictionary]!  = [NSDictionary]()
    var poiArray   : [POI] = []
    var delegate   : SocketDelegate!
    
    var latitude   : Double
    var longitude  : Double
    
    
    class var sharedInstance: Socket {
        struct Static {
            static let instance : Socket = Socket()
        }
        return Static.instance
    }
    
    //初期化
    private init() {
        let sensor : Sensor = Sensor.sharedInstance
        latitude  = sensor.latitude
        longitude = sensor.longitude
        self.socket = SocketIOClient(socketURL: Settings.socketURL , options: nil)
        
        //接続時の処理
        self.socket.on("connect" ,callback: { data , ack in
            println("socket connected")
            self.getData()
        })
        
        //バブルを受け取った時の処理
        self.socket.on("message_bubbles", callback: {data , ack in
            if let realData = data as? [NSDictionary] {
                if self.isNotExist(realData[0].objectForKey("post_id") as! Int!) {
                    self.bubblePool.append(realData[0])
                    let poi : POI = POI(
                        post_id    : realData[0].objectForKey("post_id")     as! Int,
                        latitude   : realData[0].objectForKey("latitude")    as! Double ,
                        longitude  : realData[0].objectForKey("longitude")   as! Double ,
                        altitude   : realData[0].objectForKey("altitude")    as! Double ,
                        message    : realData[0].objectForKey("message")     as! String ,
                        file_path  : realData[0].objectForKey("file_path")   as! String ,
                        posted_time: realData[0].objectForKey("posted_time") as! String)
                    self.delegate.createBubble(poi)
                }
            }
        })
        
        //画像を受け取った時の処理
        self.socket.on("response_image", callback: {data , ack in
            println("get image")
            if let readData = data as? [NSDictionary] {
                println( readData[0].objectForKey("message") as! String )
            }
        })
    }
    
    //あとから手動で接続するとき（初期化時にも接続する）
    func connect() {

        if !self.socket.connected {
            self.socket.connect()
        } else {
            println("ソケットに接続中なのであらたにせつぞくしません")
            //位置情報を再送
            getData()
        }
    }
    
    //画面遷移などでバブル情報をクリアする
    func clearBubble() {
        bubblePool.removeAll(keepCapacity: true)
    }
    
    
    private func getData() {
        println("emitted")
        
        let sensor : Sensor = Sensor.sharedInstance
        self.socket.emit("location_server", ["latitude" : sensor.latitude , "longitude" : sensor.longitude , "range" : 1500] )
    }
    
    func getPOIData() -> [POI] {
        return poiArray
    }
    
    
    // MARK : - プライベート関数
    private func isNotExist(id : Int) -> Bool {
        //if bubblePool.count == 0 { return true } //空なら問答無用でtrue
        
        var exist = true
        for (var i = 0 ; i < self.bubblePool.count ; i++) {
            exist = exist && !( ( (self.bubblePool[i] as NSDictionary).objectForKey("post_id") as! Int!) == id )
        }
        return exist
    }
}