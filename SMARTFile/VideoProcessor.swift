//
//  VideoProcessor.swift
//  SMARTFile
//
//  Created by Tom Rogers on 24/11/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation
import Photos

class VideoProcessor {
    
    
    func processNewVideos(assets:[PHAsset], completionHandler: @escaping (_ success: Bool) -> ()){
        DataManager.s
        
    }
    
    
    
    func getVideoSize (asset:PHAsset) -> Int {
        var sizeOnDisk: Int64? = 0
        let resources = PHAssetResource.assetResources(for: asset)
        
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
        }
        
        return Int(exactly: ((sizeOnDisk! / 1024) / 1024))!
        
    }

    
}
