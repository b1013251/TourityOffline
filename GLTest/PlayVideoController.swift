/*

動画再生画面

*/

import UIKit
import AVKit
import AVFoundation

class PlayVideoController: AVPlayerViewController {
    
    var avAsset    : AVAsset!
    var playerItem : AVPlayerItem!
    
    func playVideo(path : String) {
        let url : NSURL = NSURL(string: path)!
        
        avAsset    = AVURLAsset(URL: url, options: nil)
        playerItem = AVPlayerItem(asset: avAsset)
        player   = AVPlayer(playerItem: playerItem)
        
        println("再生するお")
        
        player.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


