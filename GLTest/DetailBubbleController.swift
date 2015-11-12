/*

    バブルの詳細画面

*/


import UIKit

class DetailBubbleController: UIViewController {
    
    var poi : POI! //位置情報
    var eval_count : String = "0";
    var eval       : String = "true"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var niceButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBAction func niceButtonPushed(sender: AnyObject) {
        //リクエストの生成 TODO: evalの追加
        /*
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: Settings.serverURL + "/send_eval")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = String("post_id=\(poi.post_id)").dataUsingEncoding(NSUTF8StringEncoding)
        */
        //リクエストの送信
        
        /*
        var response       : NSURLResponse?
        var error          : NSError?
        let responseData   : NSData!   = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response , error: &error)!

        
        let responseString : NSString = NSString(data:responseData,encoding:1)!

        
        niceButton.setImage(UIImage(named: "star.jpg"), forState: UIControlState.Normal)
        
        if(self.eval  != "false") {
            let plusEval = String("\(self.eval_count.toInt()! + 1)")
            titleLabel.text = "評価:\(plusEval)"
        }
        */
        
        
        
    }
    
    @IBAction func backButtonPush(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //画像を持ってくる
        /*
        if ( poi.file_path != "" ) {
            let file_name = poi.file_path.componentsSeparatedByString("/")[1]
            let url = NSURL(string: "\(Settings.serverURL)/\(file_name)")
            let mediaData :NSData = NSData(contentsOfURL: url!)!
            
            //画像なら表示、動画なら再生
            let file_type = file_name.componentsSeparatedByString(".")[1]
            if file_type == "jpg" {
                detailImage.hidden = false
                detailImage.image = UIImage(data:mediaData)
            } else if file_type == "mp4" {
                println( "\(Settings.serverURL)/\(file_name)")
                containerView.hidden    = false
                let playVideoController = self.childViewControllers[0] as! PlayVideoController
                playVideoController.playVideo("\(Settings.serverURL)/\(file_name)")
            }
        }
        */
        detailImage.image = UIImage(named: "yakei.jpg")
        detailImage.hidden = false
        
        messageLabel.text = self.poi.message

        //getEvalCount()

    }
    
    // 評価数をサーバからもってくる
    func getEvalCount() -> Int {
        //リクエストの生成 TODO: evalの追加
        //let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: Settings.serverURL + "/get_eval?post_id=\(poi.post_id)")!)
        //request.HTTPMethod = "GET"
        
        //リクエストの送信
        //var response       : NSURLResponse?
        //var error          : NSError?
        /*
        let responseData   : NSData!   = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response , error: &error)
        
        if let err = error {
            println(err)
            return 0
        }
        
        let responseString : NSString = NSString(data:responseData,encoding:1)!
        
        
        var jsonError : NSError?
        var responseJSON  = JSON (data: responseData)
        
        var responseCount = responseJSON["count"]
        self.eval_count   = responseJSON["count"].stringValue
        self.eval         = responseJSON["eval"].stringValue
        
        if responseJSON["eval"].stringValue == "true" {
            niceButton.setImage(UIImage(named: "star.jpg"), forState: UIControlState.Normal)
        }
        
        titleLabel.text = "評価:\(responseCount)"
        println(responseString)
        */
        return 0
    }


}