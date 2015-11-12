/*

    投稿時 撮影することで添付する
    撮影画面

*/

import UIKit
import AVFoundation
import AssetsLibrary
import Photos

class PhotoCaptureViewController: UIViewController  {
    
    private var videoOutput : AVCaptureStillImageOutput!
    private var filePath : String?
    
    var delegate : AppendImageDelegate! = nil
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBAction func pushedBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    @IBOutlet weak var recordButton: UIButton!
    @IBAction func recordButtonPush(sender: AnyObject) {
            //録画時
            let path = NSTemporaryDirectory()
            
            // フォルダ.
            let tempDirectory = path
            
            // ファイル名.
            filePath = "\(tempDirectory)/temp.jpg"
            
            // URL.
            let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)!
            
            // 録画開始.
//            videoOutput.startRecordingToOutputFileURL(fileURL, recordingDelegate: self)
            let connection = videoOutput.connections.last as! AVCaptureConnection
        
        videoOutput.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: {(buffer , error) in
            println("photo captured")
            let data  : NSData  = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            let image : UIImage = UIImage(data: data)!
            
            let fileURL : NSURL = NSURL(fileURLWithPath: self.filePath!)!
            let writeData : NSData = UIImageJPEGRepresentation(image, 0.9)
            
            if writeData.writeToFile(self.filePath!, atomically: true) {
                println("successed")
            } else {
                println("failed")
            }
            
            if let path = self.filePath {
                let pathURL = NSURL(fileURLWithPath: path)!
                self.delegate.returnData(image, url: pathURL, rawData: writeData , mediaType : PHAssetMediaType.Image)
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let session     : AVCaptureSession          = AVCaptureSession()
        var device      : AVCaptureDevice!
        let devices     = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        let audioDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio)
        let audioInput  = AVCaptureDeviceInput.deviceInputWithDevice(audioDevice[0] as! AVCaptureDevice, error: nil) as! AVCaptureInput
        
        
        for dev in devices {
            if (dev.position == AVCaptureDevicePosition.Back) {
                device = dev as! AVCaptureDevice
            }
        }
        
        
        let videoInput  = AVCaptureDeviceInput.deviceInputWithDevice(device, error: nil) as! AVCaptureInput
        
        session.addInput(videoInput)
        session.addInput(audioInput)
        
        
        videoOutput = AVCaptureStillImageOutput()
        
        session.addOutput(videoOutput)
        
        //セッションに追加してから変更しないとエラーはくから注意よ
        videoOutput.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        
        
        //画面表示部
        let videoLayer : AVCaptureVideoPreviewLayer =
        AVCaptureVideoPreviewLayer.layerWithSession(session) as! AVCaptureVideoPreviewLayer
        
        
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        
        self.view.layer.addSublayer(videoLayer)
        session.startRunning()
        
        self.view.bringSubviewToFront(recordButton)
        self.view.bringSubviewToFront(backButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
