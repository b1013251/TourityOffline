/*

    画面一覧から選んで添付

*/


import UIKit
import Photos

class AppendViewController: UIViewController , UICollectionViewDataSource ,UICollectionViewDelegate  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var photoAssets = [PHAsset]()
    var imageLength = 0
    var delegate  : AppendImageDelegate!
    var mediaType : PHAssetMediaType = PHAssetMediaType.Image
    var isAsset   : Bool = false //Assetによる添付かどうか
    
    //バックボタン押した
    @IBAction func pushedBackButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //コレクションびゅー
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let status : PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        //assetsの取得
        var assets : PHFetchResult = PHAsset.fetchAssetsWithMediaType(self.mediaType, options: nil)
        assets.enumerateObjectsUsingBlock({ (asset , index , stop ) -> () in
            self.photoAssets.append(asset as! PHAsset)
        })
        self.imageLength = assets.count
        
        
        //表示
        collectionView.delegate   = self
        collectionView.dataSource = self
        println(photoAssets)
        println(photoAssets.count)
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageLength
    }
    
    
    // グリッドに表示するときに呼ばれる
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : UICollectionViewCell =
        collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UICollectionViewCell
        
        
        var imageView : UIImageView = cell.viewWithTag(1) as! UIImageView
        
        let manager : PHImageManager = PHImageManager()
        manager.requestImageForAsset( self.photoAssets[indexPath.row] as PHAsset! , targetSize: CGSizeMake(100, 100),
            contentMode: PHImageContentMode.AspectFill , options: nil, resultHandler: {
                image , info in
                
                imageView.image = image
                
        })
        
        return cell
    }
    
    //グリッドをタップした時に呼ばれる
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedNumber = indexPath.row
        let selectedAsset  = self.photoAssets[selectedNumber]
        let manager : PHImageManager = PHImageManager()
        let options : PHImageRequestOptions = PHImageRequestOptions()
        options.synchronous = true
        
        manager.requestImageForAsset(selectedAsset, targetSize: CGSizeMake(100, 100),
            contentMode: PHImageContentMode.AspectFill, options: options, resultHandler: {
                image , info in
            println("selected image")
                
                
            self.delegate.returnData(image as UIImage , asset: selectedAsset)
            
        })

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


