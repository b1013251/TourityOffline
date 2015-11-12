/*

    起動時にTwitterIDからログインする

*/

import UIKit

class LoginController: UIViewController , UINavigationControllerDelegate, UIWebViewDelegate {
    
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let url     = NSURL(string:  Settings.serverURL + "/auth")!
        let request = NSURLRequest(URL: url)
        webView.delegate = self
        webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if webView.stringByEvaluatingJavaScriptFromString("document.URL") == Settings.serverURL + "/success" {
            let cookieStorage : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in cookieStorage.cookies! {
                if cookie.name == "connect.sid" {
                    println("\((cookie as! NSHTTPCookie).value)")
                }
            }
            
            //topViewSegueFromLogin
            performSegueWithIdentifier("topViewSegueFromLogin", sender: self)

        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        println("webView url: \(request.URL)")
        return true
    }

    
   }
