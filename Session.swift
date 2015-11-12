/*

    セッションに関するクラス
    ログイン処理をする

*/
/*
import Foundation

class Session : NSObject {
    
    var sessionIDCookie : String!
    var delegate        : SessionDelegate!
    
    override init() {
        self.sessionIDCookie = nil
        self.delegate        = nil
    }
    
    init(sessionIDCookie : String , delegate : SessionDelegate) {
        self.sessionIDCookie = sessionIDCookie
        self.delegate        = delegate
    }
    
    
    func sendCookie() {
        let cookies = createCookie()
        
        //リクエストの生成
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: Settings.serverURL + "/session")!)
        let header  : NSDictionary = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
        
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = header as [NSObject : AnyObject]
        
        
        //POSTリクエストの送信
        println("sessionIDを送信します")
        var response       : NSURLResponse?
        var error          : NSError?
        let responseData   : NSData!   = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response , error: &error)!
        
        if let err = error {
            println(err)
            return
        }
        
        let responseString : NSString = NSString(data:responseData,encoding:1)!
        println(responseString)
        


        if responseString == "OK" {
            println("ログインしていたようなので、そのまま画面遷移するよ")
            // cookieの更新
            
            if let httpResponse = response as? NSHTTPURLResponse {
                let cookies : [NSHTTPCookie] = NSHTTPCookie.cookiesWithResponseHeaderFields(httpResponse.allHeaderFields,
                    forURL: NSURL(string: "")!) as! [NSHTTPCookie]
                
                
                
                for cookie : NSHTTPCookie in cookies {
                    if cookie.name == "Session-Cookie" {
                        println("\(cookie.value) を受け取ったので保存します")
                        
                        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        userDefaults.setObject(cookie.value , forKey: "sessionID")
                    }
                }
            }
            
            self.delegate.sessionSuccess()
        } else {
            println("ログインされていなかったので、これからログインするよ")
            self.delegate.sessionFailure()
        }
    }
    
    func getUserInfo() {
        let cookies = createCookie()
        
        //リクエストの生成
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: Settings.serverURL + "/user_info")!)
        let header  : NSDictionary = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
        
        request.HTTPMethod = "GET"
        request.allHTTPHeaderFields = header as [NSObject : AnyObject]
        
        
        //POSTリクエストの送信
        println("送信します")
        let responseData   : NSData   = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)!
        let responseString : NSString = NSString(data:responseData,encoding:1)!
        println(responseString)
        
        if responseString == "" {
            println("no data")
        } else {
            println(responseString)
        }
    }
    
    private func createCookie() -> [NSHTTPCookie] {
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var sessionIDCookies = userDefaults.stringForKey("sessionID")
        
        if sessionIDCookies == nil {
            println("クッキーがなかったので")
            sessionIDCookies = ""
        }
        
        let properties : NSDictionary = NSDictionary(objectsAndKeys:
            Settings.serverURL    , NSHTTPCookieDomain ,
            "/"                   , NSHTTPCookiePath   ,
            "Session-Cookie"      , NSHTTPCookieName   ,
            sessionIDCookies! , NSHTTPCookieValue
        )
        
        let cookie  :  NSHTTPCookie  = NSHTTPCookie(properties: properties as [NSObject : AnyObject])!
        let cookies : [NSHTTPCookie] = [
            cookie
        ]
        
        return cookies

    }
    
    private func updateCookieUserDefaults(cookie_str : String) {
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(cookie_str, forKey: "sessionID")
    }
}
*/