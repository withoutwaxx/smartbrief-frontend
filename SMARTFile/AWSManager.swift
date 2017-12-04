//
//  uploadManager.swift
//  SMARTFile
//
//  Created by Tom Rogers on 18/11/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation
import AWSS3


protocol UploadDelegate: class {
    func updateToUploads()
    
}


final class AWSManager {
    
    static let awsManager = AWSManager()
    weak var delegate:UploadDelegate?

    
    var transferUtility = AWSS3TransferUtility.default()
    var requests:[NSManagedObject] = []
    
    
    private init() {}
    
    
    func updateRequestList () {
        let sort = NSSortDescriptor(key: "uploaded", ascending: false)
        requests = DataManager.getUploadRequests(predicates: [], sort: [sort])
        
    }
    
    
    
    func checkForUploadedNotUpdated () {
        var requestsToSend:[NSManagedObject] = []
        for request in requests {
            if(request.value(forKey: "uploaded_state") as! Bool == true) {
                requestsToSend.append(request)
                
            }
            
        }
        
        if(!requestsToSend.isEmpty) {
            RequestDelegate.newVideos(requests: requestsToSend, completionHandler: {
                (success) in
                if(success) {
                    if(self.delegate != nil) {
                        self.delegate?.updateToUploads()
                        
                    }
                }
            })
            
        }
        
    }
    
    
    
    func checkForActive () {
        var activeRequests:[NSManagedObject] = []
        for request in requests {
            if(request.value(forKey: "active_state") as! Bool == true) {
                activeRequests.append(request)
                
            }
            
        }
        
        if(!activeRequests.isEmpty) {
            return true
            
        } else {
           return false
            
        }
        
    }
    
    
    
    func checkForActive() {
        
        
    }
    
    
    
    func refreshUploads () {
        updateRequestList()
        checkForUploadedNotUpdated()
        if(checkForActive()) {
            
            
        } else {
            if(requests.count > 0) {
                
                
            }
            
        }
       
    }
    
    
    func uploadVideo(url:URL, completion:@escaping AWSS3TransferUtilityUploadCompletionHandlerBlock) {
        
        let expression:AWSS3TransferUtilityUploadExpression = AWSS3TransferUtilityUploadExpression()

        expression.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
            DispatchQueue.main.async(execute: {
                
                print("video upload progress update: \(progress.fractionCompleted)")
                
            })
        }
        
        expression.setValue("public-read", forRequestParameter: "x-amz-acl")
        expression.setValue("public-read", forRequestHeader: "x-amz-acl" )
        
        
        print("uploading mate")
        let fileURL = url
        
        transferUtility.uploadFile(fileURL,
                                   bucket: "finalsmartfilebucket",
                                   key: UuidGenerator.newUuid(),
                                   contentType: "video/mp4",
                                   expression: expression,
                                   completionHandler: completion).continueWith {
                                    (task) -> AnyObject! in
                                    if let error = task.error {
                                        print("Error: \(error.localizedDescription)")
                                    }
                                    
                                    if let _ = task.result {
                                        
                                    }
                                    return nil;
        }
    }
        
        
        
        
        //
        //        let docPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        //        let documentsDirectory: AnyObject = docPaths[0] as AnyObject
        //        let docDataPath = documentsDirectory.appendingPathComponent("newvideo.MOV") as String
        //
        //        let manager = PHImageManager.default()
        //        manager.requestAVAsset(forVideo: asset, options: nil, resultHandler: { (avasset, audio, info) in
        //            if let avassetURL = avasset as? AVURLAsset {
        //                print("asset", avassetURL.url as URL)
        //                guard let video = try? Data(contentsOf: avassetURL.url as URL) else {
        //                    return
        //                }
        //
        //                try? video.write(to: URL(fileURLWithPath: docDataPath), options: [])
        //                print(docDataPath)
        //                AWSManager.uploadVideo(url:URL(fileURLWithPath: docDataPath), completion: self.completionHandler!)
        //
        //
        //            }
        //        })
        
        
        
        
        
        
//        let uploadRequest = AWSS3TransferManagerUploadRequest()
//        
//        uploadRequest?.bucket = "smartfile-user-video17"
//        uploadRequest?.key = UuidGenerator.newUuid()
//        uploadRequest?.body = url
//        
//        let uploader:AWSS3TransferManager = AWSS3TransferManager.default()
//        
//        uploader.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
//            
//            if let error = task.error as NSError? {
//                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
//                    switch code {
//                    case .cancelled, .paused:
//                        break
//                    default:
//                        print("Error uploading: \(uploadRequest?.key ?? "") Error: \(error)")
//                    }
//                } else {
//                    print("Error uploading: \(uploadRequest?.key ?? "") Error: \(error)")
//                }
//                return nil
//            }
//            
//            let uploadOutput = task.result
//            print("Upload complete for: \(uploadRequest?.key ?? "")")
//            return nil
//        })
        
    
    
}
