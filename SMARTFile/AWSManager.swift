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

protocol NewVideoDelegate: class {
    func updateToVideo()
    
}


final class AWSManager {
    
    static let awsManager = AWSManager()
    weak var uploadDelegate:UploadDelegate?
    weak var videoDelegate:NewVideoDelegate?

    
    var transferUtility = AWSS3TransferUtility.default()
    var requests:[NSManagedObject] = []
    var activeRequests:[NSManagedObject] = []

    
    
    private init() {}
    
    
    func updateRequestLists () {
        let sort = NSSortDescriptor(key: Constants.FIELD_VIDEO_ADDED, ascending: false)
        requests = DataManager.getUploadRequests(predicates: [], sort: [sort])
        var predicates:[NSPredicate] = []
        predicates.append(NSPredicate(format: "active_state = %@", true as CVarArg))
        activeRequests = DataManager.getUploadRequests(predicates: [], sort: [sort])
        
    }
    
    
    
    func checkForUploadedNotUpdated () {
        var requestsToSend:[NSManagedObject] = []
        for request in requests {
            if(request.value(forKey: Constants.FIELD_UPLOAD_UPLOADED_STATE) as! Bool == true) {
                requestsToSend.append(request)
                
            }
            
        }
        
        if(!requestsToSend.isEmpty) {
            RequestDelegate.newVideos(requests: requestsToSend, completionHandler: {
                (success) in
                if(success) {
                    if(self.videoDelegate != nil) {
                        self.videoDelegate?.updateToVideo()
                        
                    }
                }
            })
            
        }
        
    }
    
    
    
    func updateActiveUploads (activeUploads:[AWSS3TransferUtilityUploadTask], completionHandler: @escaping (_ success: Bool) -> ()) {
        
        var requestIds:[Int] = []
        var taskIds:[Int] = []
        var incorrectRequests:[Int] = []
        var incorrectRequestFound = false
        
        for request in activeRequests {
            requestIds.append(request.value(forKey: Constants.FIELD_UPLOAD_TASK_ID) as! Int)
            
        }
        
        for upload in activeUploads {
            taskIds.append(Int(upload.taskIdentifier))
            
        }
        
        for req in requestIds {
            if(!taskIds.contains(req)) {
                incorrectRequests.append(req)
                incorrectRequestFound = true
                
            }
            
        }

        
        if(incorrectRequestFound) {
            DataManager.resetUploadTasks(ids:incorrectRequests, completionHandler: {
                (success) in
                if(self.uploadDelegate != nil) {
                    self.uploadDelegate?.updateToUploads()
                    
                }
                self.updateRequestLists()
                completionHandler(true)
                
            })
            
        }
    
    }
    
    
    
    func validateActiveUpload(task:AWSS3TransferUtilityUploadTask) {
        
        
    }
    
    
    
    func checkForActive ( completionHandler: @escaping (_ active: Bool) -> ()) {
        
        updateRequestLists()
    
        transferUtility.getUploadTasks().continueWith(block: {
            (task) in
          
            if let uploadTasks = task.result as? [AWSS3TransferUtilityUploadTask] {
                
                if((self.activeRequests.isEmpty) && (uploadTasks.isEmpty)){
                    completionHandler(false)
                    
                }
                
                if(self.activeRequests.count != uploadTasks.count) {
                    self.updateActiveUploads(activeUploads: uploadTasks, completionHandler: {
                        (success) in
                        for upload in uploadTasks {
                            validateActiveUpload(upload)
                            
                        }
                        
                    })
                    completionHandler(true)
        
                } else {
                    completionHandler(true)
                    
                }
                
            }
  
        })
    
    }
    
    
    
    func refreshUploads () {
        updateRequestLists()
        checkForUploadedNotUpdated()
        checkForActive { (success) in
            if(success) {
                
                
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
        //        
        
        
        
        
        
        
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
