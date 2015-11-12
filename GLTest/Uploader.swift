/*

    サーバに投稿するクラス

*/

import Foundation
import UIKit
import Photos

// 投稿形式を列挙型で定義
enum MessageStatus {
    case Text   //テキストのみ
    case Video  //テキストと動画
    case Image  //テキストと画像
    
    func toString() -> String {
        switch self {
        case .Text:
            return "Text"
        case .Image:
            return "Image"
        case .Video:
            return "Video"
        }
    }
}

/* アップローダに画像、動画、メッセージを送信するクラス*/
class Uploader : NSObject , NSURLSessionDelegate {
    //初期化すべきメンバ
    var asset : PHAsset!
    var message : String
    var status : MessageStatus
    var delegate : PostViewController!
    
    //プライベートメンバ
    private var data : NSData!
    private var type : String!
    private var imageData   : UIImage!
    private var filename = "filename" // 受信側で使われないのでなんでもよろし
    
    
    /**
    PHAssetから初期化（テキストのみの場合）
    
    - parameter asset:   画像・動画のアセット
    - parameter message: メッセージ内容
    
    - returns: void
    */
    init(asset : PHAsset , message : String) {
            self.asset   = asset
            self.message = message
            self.status  = MessageStatus.Text
    }
    
    
    /**
    PHAssetから初期化（画像・動画を含む）
    
    - parameter asset:   画像・動画のアセット
    - parameter message: メッセージ内容
    - parameter status:  画像か動画か（判別にMessageStatus列挙型を使用）
    
    - returns: void
    */
    init(asset : PHAsset , message: String , status: MessageStatus) {
            self.asset   = asset
            self.message = message
            self.status  = status
    }
    
    
    /**
    送信する生データから初期化
    
    - parameter data:    画像・動画のデータ
    - parameter message: メッセージ内容
    - parameter status:  画像か動画か
    
    - returns: void
    */
    init(data : NSData , message : String , status:MessageStatus) {
        self.data    = data
        self.message = message
        self.status  = status
    }
    
    /**
    メッセージデータのみで初期化
    
    - parameter message: メッセージ内容
    
    - returns: void
    */
    init(message : String) {
        self.message = message
        self.status = MessageStatus.Text
    }
    
    /**
    画像をアップロードする．
    */
    func upload(delegate : PostViewController) {
        //アップロード後に呼び出すクラスの準備
        self.delegate = delegate
        
        //アップロードする内容に応じて準備
        let sensor = Sensor.sharedInstance
        
        if self.status == MessageStatus.Image {
            readyImageData()
        } else if self.status == MessageStatus.Video {
            readyVideoData()
        } else {
            readyTextData()
        }
        
        //セッション設定
        let sessionConfig : NSURLSessionConfiguration =
        NSURLSessionConfiguration.defaultSessionConfiguration()
        let session       : NSURLSession = NSURLSession(configuration: sessionConfig, delegate: self , delegateQueue:  NSOperationQueue.mainQueue())
        
        
        //リクエストの生成
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: Settings.serverURL + "/upload")!)

        let boundary = "-miraibound"
        var httpBody : NSMutableData = NSMutableData()
        httpBody.appendData(String("--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
        //          動画なのか画像なのか文章のみなのか
        httpBody.appendData(String("Content-Disposition: from-data; name=\"title\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody.appendData(String("\(self.status.toString())\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody.appendData(String("--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
        //          メッセージ内容
        httpBody.appendData(String("Content-Disposition: from-data; name=\"message\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody.appendData(String("\(self.message)\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody.appendData(String("--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
        httpBody.appendData(String("Content-Disposition: from-data; name=\"latitude\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody.appendData(String("\(sensor.latitude)\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody.appendData(String("--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
        httpBody.appendData(String("Content-Disposition: from-data; name=\"longitude\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody.appendData(String("\(sensor.longitude)\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody.appendData(String("--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
        httpBody.appendData(String("Content-Disposition: from-data; name=\"altitude\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody.appendData(String("\(sensor.altitude)\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody.appendData(String("--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
        //          バイナリデータ（テキストの場合はスルー）
        if self.status == MessageStatus.Image || self.status == MessageStatus.Video {
            httpBody.appendData(String("Content-Disposition: from-data; name=\"fileup\"").dataUsingEncoding(NSUTF8StringEncoding)!)
            httpBody.appendData(String("filename=\"\(filename)\"\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            httpBody.appendData(String("Content-Type:\(type)\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            httpBody.appendData(data)
            httpBody.appendData(String("\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            httpBody.appendData(String("--\(boundary)--\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        request.HTTPMethod = "POST"
        request.HTTPBody  = httpBody
        request.setValue("multipart/form-data ; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        //          クッキーの追加
        let cookies = readCookie()
        let header  : NSDictionary = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
        request.allHTTPHeaderFields = header as [NSObject : AnyObject]
        
        //タスクの生成・アップロード！
        println("uploading")
        let task : NSURLSessionUploadTask = session.uploadTaskWithRequest(request, fromData: nil)
        task.resume()
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        println("didCompleteWithError")
        
        // エラーが有る場合にはエラーのコードを取得.
        println(error?.code)
        delegate.uploadFinish()
    }

    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void) {
        
        println("willPerformHTTPRedirection")
        
    }
    
    

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        println("didSendBodyData")
    }
    
    // MARK: - プライベート関数群
    private func readyImageData() {
        let manager     : PHImageManager = PHImageManager()
        
        //アセットバージョン
        if self.asset != nil {
            let options : PHImageRequestOptions = PHImageRequestOptions()
            options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
            options.synchronous = true
            
            // ここでデータを圧縮した状態で取得
            manager.requestImageForAsset(self.asset, targetSize: CGSizeMake(320 ,240),
                contentMode: PHImageContentMode.AspectFill, options: options, resultHandler: {
                    image , info in
                    
                    self.imageData = image as UIImage
                }
            )
            
            data = UIImageJPEGRepresentation(imageData , 0.8)
        }
        
        type = "image/jpeg"
    }
    
    private func readyVideoData() {
        let manager     : PHImageManager = PHImageManager()
        
        //アセットバージョン
        if self.asset != nil {
            let options : PHImageRequestOptions = PHImageRequestOptions()
            options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
            options.synchronous = true
            
            // ここでデータを圧縮した状態で取得
            manager.requestImageForAsset(self.asset, targetSize: CGSizeMake(320 ,240),
                contentMode: PHImageContentMode.AspectFill, options: options, resultHandler: {
                    image , info in
                    
                    self.imageData = image as UIImage
                }
            )
            
            data = UIImageJPEGRepresentation(imageData , 0.8)
        }
        
        type = "video/mpeg"
    }
    
    private func readyTextData() {
        
    }
    
    private func readCookie() -> [NSHTTPCookie] {
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var sessionIDCookies = userDefaults.stringForKey("sessionID")
        
        if sessionIDCookies == nil {
            println("クッキーがなかったので")
            sessionIDCookies = ""
        }
        
        let properties : NSDictionary = NSDictionary(objectsAndKeys:
            Settings.serverURL    , NSHTTPCookieDomain ,
            "/"                   , NSHTTPCookiePath   ,
            "connect.sid"      , NSHTTPCookieName   ,
            sessionIDCookies! , NSHTTPCookieValue
        )
        
        let cookie  :  NSHTTPCookie  = NSHTTPCookie(properties: properties as [NSObject : AnyObject])!
        let cookies : [NSHTTPCookie] = [
            cookie
        ]
        
        return cookies
    }


}