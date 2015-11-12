/*

    添付画面から選んだ時のデータを受け取るデリゲート

*/


import Foundation
import Photos


protocol AppendImageDelegate {
    func returnData(imageData : UIImage , asset : PHAsset) -> Void //動画に関してもサムネイルを返すだけなので画像
    
    func returnData(imageData : UIImage , url : NSURL , rawData : NSData , mediaType : PHAssetMediaType )
}
