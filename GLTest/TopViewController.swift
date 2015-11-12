/*

    トップメニューのコントローラ

*/

import UIKit
import AVFoundation
import SpriteKit
import CoreLocation
import CoreMotion
import SpriteKit

class TopViewController: UIViewController  {
    
    
    @IBAction func pushMyPage(sender: AnyObject) {
        performSegueWithIdentifier("mypageViewSegue", sender: self)
    }
    
    // MARK: - Segue
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        //nothing
        return true;
    }
    
    // MARK: - ビューコントローラ
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sensor = Sensor.sharedInstance
        sensor.start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

