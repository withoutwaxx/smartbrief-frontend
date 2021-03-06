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



final class VideoManager {
    
    static let sharedInstance = VideoManager()
    
    private init() {
        
        
    }
    
    
    
    func processNewVideos(assets:[PHAsset], pProjectId:String, completionHandler: @escaping (_ success: Bool, _ duplicate:Bool) -> ()) {
        
        var requests:[UploadRequest] = []
        
        for asset in assets {
            
            let videoId = UuidGenerator.newUuid()
            let projectId = pProjectId
            let taskId = -1
            let userId = User.id
            let localId = asset.localIdentifier
            let desc = ""
            let url = videoId
            let length:Int = Int(asset.duration)
            let size = getVideoSize(asset: asset)
            let added = Date()
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
                    try FileManager.default.removeItem(atPath: url.absoluteString)
                
                } catch {
                    print(error)
        
                }
            }
            
        }
    
    }
    
    
    //Removes all files from users own dir. Used to ensure files do not build up if uploads fail
    func clearUsersDirectory() {
        let fileManager = FileManager.default
        
        let docPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsDirectory: AnyObject = docPaths[0] as AnyObject
        
        let dirPath:String = documentsDirectory.appendingPathComponent(User.id)
        
        if(fileManager.fileExists(atPath: dirPath)) {
            do {
                let filePaths = try fileManager.contentsOfDirectory(atPath: dirPath)
                for filePath in filePaths {
                    print(filePath)
                    try fileManager.removeItem(atPath: dirPath + "/" + filePath)
                }
            } catch {
                print("Could not clear temp folder: \(error)")
                print("full directory us : \(dirPath)")
            }
            
        }
    
    }
    
        
    
    
    func createDirectory () -> (Bool, URL?, String) {
        let docPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsDirectory: AnyObject = docPaths[0] as AnyObject
        
        let filePath:String = documentsDirectory.appendingPathComponent(User.id)
        
        let fileManager = FileManager.default
        
        var isDir : ObjCBool = false
        
        if fileManager.fileExists  (atPath: filePath, isDirectory:&isDir) {
            if isDir.boolValue {
                return (true, URL(fileURLWithPath: filePath), "what")
                
            } else {
                deleteVideoFile(localUrl: filePath)
                do {
                    try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
                    return (true, URL(fileURLWithPath: filePath), "weird")
                } catch let error as NSError {
                    print("Unable to create directory \(error.debugDescription)")
                    return (false, nil, "first first")
                }
                
            }
        } else {
            do {
                try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
                return (true, URL(fileURLWithPath: filePath), "")
            } catch let error as NSError {
                print("Unable to create directory \(error.debugDescription)")
                return (false, nil, "second second")
            }
            
        }
        
    }
    
        
    
    
    func createVideoFile (request:NSManagedObject, completionHandler: @escaping (_ success: Bool, _ url:URL?, _ err:String?) -> ()) {
        
        let dir = createDirectory()
        
        if(dir.0 == true) {
            print("true")
            
        } else {
           print("here")
            
        }
        
        if(dir.0 == true) {
            
            let docDataPath = dir.1?.appendingPathComponent("\(request.value(forKey: Constants.FIELD_VIDEO_ID) as! String).MOV")
                        
            if let newPath = docDataPath {
                
                print("here")
                
                let manager = PHImageManager.default()
                
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [request.value(forKey: Constants.FIELD_UPLOAD_LOCAL_ID) as! String], options: nil).firstObject
                
                print("here two two")
                
                if let uAsset = asset {
                    manager.requestAVAsset(forVideo: uAsset, options: nil, resultHandler: { (avasset, audio, info) in
                        if let avassetURL = avasset as? AVURLAsset {
                            
                            print("here three")
                             
                                guard let video = try? Data(contentsOf: avassetURL.url as URL) else {
                                    print("here four")
                                    completionHandler(false, nil, "first")
                                    return
                                }
                                do {
                                    try video.write(to: URL(fileURLWithPath: newPath.path), options: [])
                                    print("here two")
                                    completionHandler(true, newPath, "correct")
                                    
                                } catch {
                                    completionHandler(false, nil, "second")
                                    
                                }
                            
                        }
                    })
                    
                }
                
            }
            
        } else {
            completionHandler(false, nil, dir.2)
            
        }
        
        
    
    }
    

    
}
