/*

        AR画面のコントローラ

*/

import UIKit
import AVFoundation
import SpriteKit
import CoreLocation
import CoreMotion
import SpriteKit

class ViewController: UIViewController , DetailDelegate{
  
    // MARK: - カメラ
    var cameraDevice :AVCaptureDevice!
    var cameraSession:AVCaptureSession!
    var cameraImage  :AVCaptureStillImageOutput!
    var videoLayer   : AVCaptureVideoPreviewLayer!
    
    
    // MARK: - 位置情報メンバ
    var longitude : Double = 0.0
    var latitude  : Double = 0.0
    var heading   : Double = 0.0
    var yaw       : Double = 0.0
    var roll      : Double = 0.0
    var pitch     : Double = 0.0
    
    //その他
    var poiForSendingDetail : POI! //詳細画面に遷移する際に送るPOIの入れ物

    //ボタンを押して
    @IBOutlet weak var postButtonOutlet: UIButton!
    @IBAction func postButton(sender: AnyObject) {
        
    }
    
    //バックボタン
    @IBOutlet weak var backButton: UIButton!
    @IBAction func pushedBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - ビューコントローラ
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        cameraInit()
        cameraSession.startRunning()
        skInit()
        
        self.view.bringSubviewToFront(postButtonOutlet)
        self.view.bringSubviewToFront(backButton)
        
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        cameraSession.stopRunning()
        videoLayer.removeFromSuperlayer()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK : -カメラ初期化
    private func cameraInit() {
        //初期化処理
        cameraSession = AVCaptureSession()
        
        //デバイスの取得し背面カメラを指定
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if ( device.position == AVCaptureDevicePosition.Back) {
                cameraDevice = device as! AVCaptureDevice
            }
        }
        
        //入力を指定して追加
        let videoInput = AVCaptureDeviceInput.deviceInputWithDevice(cameraDevice, error: nil) as! AVCaptureDeviceInput
        cameraSession.addInput(videoInput)
        
        //出力先を指定して追加
        cameraImage = AVCaptureStillImageOutput()
        cameraSession.addOutput(cameraImage)
        
        
        //画像表示レイヤ
        videoLayer = AVCaptureVideoPreviewLayer.layerWithSession(cameraSession) as! AVCaptureVideoPreviewLayer
        videoLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        //レイヤを追加
        self.view.layer.addSublayer(videoLayer)
        
    }

    
    // MARK: - Sprite Kit初期化
    private func skInit() {
        //別途用意したシーンを追加
        let scene : BubbleScene = BubbleScene()
        scene.detailDelegate = self
        
        //SpriteKit用のViewを作成
        let skView:SKView = SKView(frame: self.view.frame)
        skView.allowsTransparency = true
        skView.userInteractionEnabled = true
        
        //デバッグ情報を表示
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        //skView.showsDrawCount = true
        
        
        //シーンを追加
        skView.presentScene(scene)
        
        //作成したViewをサブビューとして追加
        self.view.addSubview(skView)

    }
    
    // MARK: - 画面遷移
    func moveDetailView(poi : POI) {
        self.poiForSendingDetail = poi
        performSegueWithIdentifier("detailBubbleSegue", sender: self)
        
    }
    
    //遷移前の処理
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailBubbleSegue" {
            (segue.destinationViewController as! DetailBubbleController).poi = self.poiForSendingDetail
        }
    }
}
