/*

 クッキーに関するクラスメソッド群

*/
import Foundation


class CookieHelper: NSObject {
    
    /**
    セッション用クッキーを取得
    
    - returns: セッションを含むクッキー：なければ空のクッキー
    */
    class func getCookie() -> [NSHTTPCookie] {
        let userDefaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var sessionIDCookies = userDefaults.stringForKey("sessionID")
        
        if sessionIDCookies == nil {
            println("クッキーがありません．")
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
