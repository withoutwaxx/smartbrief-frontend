//
//  VideoProcessor.swift
//  SMARTFile
//
//  Created by Tom Rogers on 24/11/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation
import Photos
import CoreData

class VideoProcessor {
    
    
    func processNewVideos(assets:[PHAsset], pProjectId:String, completionHandler: @escaping (_ success: Bool, _ duplicate:Bool) -> ()) {
        
        var requests:[UploadRequest] = []
        
        for asset in assets {
            
            let videoId = UuidGenerator.newUuid()
            let projectId = pProjectId
            let taskId = 0
            let userId = User.id
            let localId = asset.localIdentifier
            let desc = ""
            let url = "\(Constants.s3BaseURL)\(videoId)"
            let length:Int = Int(asset.duration)
            let size = getVideoSize(asset: asset)
            let added = Date()
            print("short date ", added)
            let uploadedState = false
            let activeState = false
            let local_url = ""
            
            let request = UploadRequest(videoId: videoId, userId: userId, projectId: projectId, taskId: taskId, localId: localId, desc: desc, url: url, length: length, size: size, added: added, uploadedState: uploadedState, activeState: activeState, localUrl: local_url)
            requests.append(request)
            
        }
        
        DataManager.saveUploadRequests(uploads: requests, completionHandler: {
            (success, duplicate) in
            if(success) {
                completionHandler(success, duplicate)
            
            } else {
                completionHandler(false, duplicate)
            
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
    
    
    
    func deleteVideoFile (localUrl:String) {
        if let url = URL(string: localUrl) {
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                    print("deleted \(url.path)")
                
                } catch {
                    print("Unable to delete file")
        
                }
            }
            
        }
    
    }
        
    
        
    
    
    func createVideoFile (request:NSManagedObject) -> (Bool, String){
        let docPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = docPaths[0] as AnyObject
        let docDataPath = documentsDirectory.appendingPathComponent("\(videoId).MOV") as String
        
        let manager = PHImageManager.default()
        
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil).firstObject
        
        manager.requestAVAsset(forVideo: asset!, options: nil, resultHandler: { (avasset, audio, info) in
            if let avassetURL = avasset as? AVURLAsset {
                
                guard let video = try? Data(contentsOf: avassetURL.url as URL) else {
                    return
                }
                
                try? video.write(to: URL(fileURLWithPath: docDataPath), options: [])
                print(docDataPath)
                
                
                
            }
        })
        
    }
    

    
}
