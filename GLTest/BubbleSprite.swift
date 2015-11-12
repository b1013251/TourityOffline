/*


    バブル１つを表すSpriteNode

*/

import Foundation
import SpriteKit

class BubbleSprite : SKSpriteNode {
    var detailDelegate : DetailDelegate!
    var poi            : POI!
    var randx           : Int = 0
    var randy           : Int = 0
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        println("touched \(self.name)")
        self.detailDelegate.moveDetailView( self.poi )
    }
    
    
}