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
    
    
    func processNewVideos(assets:[PHAsset], pProjectId:String, completionHandler: @escaping (_ success: Bool) -> ()) {
        
        var requests:[UploadRequest] = []
        
        for asset in assets {
            
            let videoId = UuidGenerator.newUuid()
            let projectId = pProjectId
            let taskId = ""
            let userId = User.id
            let localId = asset.localIdentifier
            let desc = ""
            let url = "\(Constants.s3BaseURL)\(videoId)"
            let length:Int = Int(asset.duration)
            let size = getVideoSize(asset: asset)
            let uploaded = Date()
            let sent = false
            let active = false
            
            let request = UploadRequest(videoId: videoId, userId: userId, projectId: projectId, taskId: taskId, localId: localId, desc: desc, url: url, length: length, size: size, uploaded: uploaded, sent: sent, active: active)
            requests.append(request)
            
        }
        
        DataManager.saveUploadRequests(uploads: requests, completionHandler: {
            (success) in
            if(success) {
                completionHandler(success)
            
            } else {
                completionHandler(false)
            
            }
        })
        
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
