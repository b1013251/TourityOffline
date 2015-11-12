/*

    マイページ画面のコントローラ

*/

import UIKit
import Photos

class MyPageController: UIViewController {
    
    @IBAction func pushBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: Settings.serverURL + "/user_info")!,
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
        } else {
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


