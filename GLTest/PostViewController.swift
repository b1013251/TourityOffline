/*

    投稿画面のコントローラ

*/


import UIKit
import AVFoundation
import SpriteKit
import CoreLocation
import CoreMotion
import SpriteKit
import MobileCoreServices
import Photos

class PostViewController: UIViewController , UITextFieldDelegate ,
    UINavigationControllerDelegate ,UIImagePickerControllerDelegate ,UITextViewDelegate, AppendImageDelegate {

    //画面コンポーネントと付随するメンバ
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var previewText: UILabel!
    @IBOutlet weak var previewImage: UIImageView!
    var imageData    : UIImage!
    var imageRawData : NSData!
    
    //投稿画像に必要なアセットインスタンス
    var imageAsset : PHAsset!
    
    //メディアタイプ（ボタン押下時に使用）
    var mediaType  : PHAssetMediaType = PHAssetMediaType.Image
    
    
    private func moveToVideoRecord() {
        println("record")
        performSegueWithIdentifier("videoRecordSegue", sender: self)
    }
    
    private func moveToPhotoCapture() {
        println("photo")
        performSegueWithIdentifier("photoCaptureSegue", sender: self)
    }
    
    private func moveToAppend() {
        performSegueWithIdentifier("appendSegue", sender: self)
    }
    
    //キーボードを閉じる（同時にプレビュー反映）
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if count(textView.text!) > 6 {
            var idx: String.Index
            idx = advance(textView.text!.startIndex,6)
            
            previewText.text = textView.text!.substringToIndex(idx) + "..."
        } else {
            previewText.text = textView.text!
        }
        
        self.textView.resignFirstResponder() //キーボードを閉じる
    }
    
    
    //textViewの改行を禁止し，キーボードを閉じるデリゲート
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange,
        replacementText text: String) -> Bool {
            if text == "\n" {
                
                if count(textView.text!) > 6 {
                    var idx: String.Index
                    idx = advance(textView.text!.startIndex,6)
                    
                    previewText.text = textView.text!.substringToIndex(idx) + "..."
                } else {
                    previewText.text = textView.text!
                }
                
                self.textView.resignFirstResponder() //キーボードを閉じる
                return false
            }
            return true
    }
    
    //画像を添付（撮影or添付）
    @IBAction func imageButton(sender: AnyObject) {
        let alert : UIAlertController =
        UIAlertController(title: "添付or撮影", message: "どうするよ",
            preferredStyle:UIAlertControllerStyle.Alert)
        let appendAction : UIAlertAction =
        UIAlertAction(title: "アルバムから添付", style: UIAlertActionStyle.Default,
            handler: {(action : UIAlertAction!) -> () in
                self.mediaType = PHAssetMediaType.Image
                self.moveToAppend(  )
        })
        
        let recordAction : UIAlertAction =
        UIAlertAction(title: "撮影して添付", style: UIAlertActionStyle.Default,
            handler: {(action:UIAlertAction!) -> () in
                self.moveToPhotoCapture()
        })
        
        let cancelAction : UIAlertAction =
        UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Default,
            handler: {(action:UIAlertAction!) -> () in
                //何もしない
        })
        
        alert.addAction(appendAction)
        alert.addAction(recordAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //動画を添付（撮影or添付）
    @IBAction func videoButton(sender: AnyObject) {
        let alert : UIAlertController =
            UIAlertController(title: "添付or録画", message: "どうするよ",
                preferredStyle:UIAlertControllerStyle.Alert)
        let appendAction : UIAlertAction =
        UIAlertAction(title: "アルバムから添付", style: UIAlertActionStyle.Default,
            handler: {(action : UIAlertAction!) -> () in
                self.mediaType = PHAssetMediaType.Video
                self.moveToAppend(  )
        })
        
        let recordAction : UIAlertAction =
        UIAlertAction(title: "録画して添付", style: UIAlertActionStyle.Default,
            handler: {(action:UIAlertAction!) -> () in
                self.moveToVideoRecord()
        })
        
        let cancelAction : UIAlertAction =
        UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Default,
            handler: {(action:UIAlertAction!) -> () in
                // なにもしない
        })
        
        alert.addAction(appendAction)
        alert.addAction(recordAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //戻るボタン
    @IBAction func pushedBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //投稿ボタン
    @IBAction func pushedPostButton(sender: AnyObject) {
        
        var status : MessageStatus!
        switch(self.mediaType) {
        case PHAssetMediaType.Image :
            status = MessageStatus.Image
            break
        case PHAssetMediaType.Video :
            status = MessageStatus.Video
            break
        default:
            status = MessageStatus.Text
            break
        }
        
        //動画・画像のアップロード
        var uploader : Uploader!
        if imageData != nil && imageAsset != nil {
            uploader = Uploader(asset: self.imageAsset!  , message: textView.text, status: status)
            uploader.upload(self)
        } else if imageRawData != nil {
            uploader = Uploader(data: self.imageRawData! , message: textView.text, status: status)
            uploader.upload(self)
        } else {
            println("only text upload")
            uploader = Uploader(message: textView.text)
            uploader.upload(self)
        }
        
        let wrapView : UIView = UIView(frame: self.view.bounds)
        wrapView.backgroundColor = UIColor.blackColor()
        wrapView.alpha = 0.5
        
        let indicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0.0, 0.0, 32.0, 32.0))
        indicator.center = CGPointMake(self.view.bounds.size.width / 2 , self.view.bounds.size.height / 2)
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        
        self.view.addSubview(wrapView)
        self.view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    func uploadFinish() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - ビューコントローラ
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.imageData != nil {
            self.previewImage.image = imageData
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - データ受信
    func returnData(image : UIImage , asset : PHAsset) -> () {
        println("called returnData")
        self.imageData = image
        self.imageAsset = asset
    }
    
    func returnData(image : UIImage , url : NSURL , rawData : NSData , mediaType : PHAssetMediaType) -> () {
        println("called returnData")
        
        self.imageAsset = nil
        
        self.imageData = image
        self.mediaType = mediaType
        self.imageRawData = rawData
    }
    
    //遷移前の処理
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "appendSegue" {
            (segue.destinationViewController as! AppendViewController).delegate = self
            (segue.destinationViewController as! AppendViewController).mediaType = self.mediaType
        }
        
        
        if segue.identifier == "videoRecordSegue" {
            (segue.destinationViewController as! VideoRecordViewController).delegate = self
        }
        
        if segue.identifier == "photoCaptureSegue" {
            (segue.destinationViewController as! PhotoCaptureViewController).delegate = self
        }
    }
    

}


