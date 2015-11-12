/*

    Twitterログインのボタン

*/

import UIKit

class FirstViewController: UIViewController , NSURLSessionDelegate {
    
    @IBOutlet weak var overwrapView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //リクエストの生成
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: Settings.serverURL + "/check_user")!,
            cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10.0)
        let header  : NSDictionary = NSHTTPCookie.requestHeaderFieldsWithCookies(CookieHelper.getCookie())
        var error   : NSError?
        var response : NSURLResponse?
        
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = header as [NSObject : AnyObject]
        
        
        var responseData = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil , error: &error)
        
        if error == nil {
            let responseString : NSString = NSString(data: responseData! ,encoding:1)!
            println(responseString)
            
            if responseString == "login_ok" {
                println("login_ok")
                performSegueWithIdentifier("topViewSegue", sender: self)
            } else {
                //ログインできない場合の処理
                println(responseString)
                overwrapView.hidden = true
            }
        } else {
            //サーバエラー
            messageLabel.text = "サーバに接続できません"
            println("サーバに接続できません")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

