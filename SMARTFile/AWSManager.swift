//
//  uploadManager.swift
//  SMARTFile
//
//  Created by Tom Rogers on 18/11/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation
import AWSS3
import CoreData


protocol UploadDelegate: class {
    func updateToUploads()
    
}

protocol NewVideoDelegate: class {
    func updateToVideo()
    
}

protocol UploadProgressDelegate: class {
    func updateToProgress(progress:Double)
    
}

private let _awsManager = AWSManager()


class AWSManager {
    
    weak var uploadDelegate:UploadDelegate?
    weak var videoDelegate:NewVideoDelegate?
    weak var uploadProgressDelegate:UploadProgressDelegate?
    
    var transferUtility:AWSS3TransferUtility
    var requests:[NSManagedObject] = []
    var activeRequests:[NSManagedObject] = []
    var completionHandler:AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var uploadExpression:AWSS3TransferUtilityUploadExpression?
    var context:NSManagedObjectContext?
    
    
    class var awsManager: AWSManager {
        return _awsManager
        
    }
    
    
    init() {
        let credentialProvider = AWSCognitoCredentialsProvider (
            regionType: .EUWest2,
            identityPoolId: "eu-west-2:206e8f66-fe59-44dc-8cf5-2b6038bcf7a5"
        )
        
        let configuration = AWSServiceConfiguration(region: .EUWest2, credentialsProvider: credentialProvider)
        let config:AWSS3TransferUtilityConfiguration = AWSS3TransferUtilityConfiguration()
        config.bucket = "finalsmartfilebucket"
        config.isAccelerateModeEnabled = true
        AWSS3TransferUtility.register(with: configuration!, transferUtilityConfiguration: config, forKey: "UPLOAD_MANAGER")
        transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "UPLOAD_MANAGER")
        
    }
    
    
    func updateRequestLists () {
        let sort = NSSortDescriptor(key: Constants.FIELD_VIDEO_ADDED, ascending: false)
        requests = DataManager.getUploadRequests(predicates: [], sort: [sort], bg: true, context: context )
        var predicates:[NSPredicate] = []
        predicates.append(NSPredicate(format: "active_state = %@", true as CVarArg))
        activeRequests = DataManager.getUploadRequests(predicates: [], sort: [sort], bg: true, context: context )
        
        
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
                        DispatchQueue.main.async {
                            self.videoDelegate?.updateToVideo()
                        }
                        
                        
                    }
                    self.updateRequestLists()
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
        
        var currentRequest:NSManagedObject?
        var found = false
        
        for request in requests {
            if(request.value(forKey: Constants.FIELD_UPLOAD_TASK_ID) as! Int == Int(task.taskIdentifier)) {
                currentRequest = request
                found = true
                break
                
            }
            
        }
        
        if(found) {
            if(currentRequest?.value(forKey: Constants.FIELD_UPLOAD_ACTIVE) as! Bool  == false) {
                if(!((currentRequest?.value(forKey: Constants.FIELD_UPLOAD_LOCAL_URL) as! String).isEmpty)) {
                    DataManager.updateSingleUploadTask(findField: Constants.FIELD_VIDEO_ID, findValue: currentRequest?.value(forKey: Constants.FIELD_VIDEO_ID) as! String, updateField: Constants.FIELD_UPLOAD_ACTIVE, updateValueBool: true, updateValueString: "", updateTypeBool: true, context: context!)
                    
                } else {
                    task.cancel()
                    DataManager.resetUploadTasks(ids: [currentRequest?.value(forKey: Constants.FIELD_UPLOAD_TASK_ID) as! Int], completionHandler: { (success) in
                        if(self.videoDelegate != nil) {
                            self.videoDelegate?.updateToVideo()
                            
                        }
                        
                    })
                    
                }
                
            }
            
        } else {
            task.cancel()
            
        }
        
    }
    
    
    
    func updateActive ( completionHandler: @escaping (_ active: Bool) -> ()) {
        
        updateRequestLists()
        
        transferUtility.getUploadTasks().continueWith(block: {
            (task) in
            
            if let uploadTasks = task.result as? [AWSS3TransferUtilityUploadTask] {
                
                if(self.activeRequests.count != uploadTasks.count) {
                    self.updateActiveUploads(activeUploads: uploadTasks, completionHandler: {
                        (success) in
                        for upload in uploadTasks {
                            self.validateActiveUpload(task: upload)
                            
                        }
                        
                    })
                    completionHandler(true)
                    
                } else {
                    completionHandler(true)
                    
                }
                
                return nil
                
            }
            
            return nil
            
        })
        
        updateRequestLists()
        
    }
    
    
    
    func awakenUploads (context:NSManagedObjectContext) {
        self.context = context
        updateRequestLists()
        checkForUploadedNotUpdated()
        updateActive(completionHandler: {
            
        (complete) in
        
            if(self.activeRequests.count == 0) {
                if(self.requests.count > 0) {
                    self.startNewUpload(request: self.requests[0])
                    
                }
                
            }
            
        })
        
    }
    
    
    func startNewUpload(request:NSManagedObject) {
        
        self.uploadExpression = AWSS3TransferUtilityUploadExpression()
        let fileURL:URL
        let videoProcessor = VideoProcessor()
        
        uploadExpression?.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
            DispatchQueue.main.async(execute: {
                if(self.uploadProgressDelegate != nil) {
                    self.uploadProgressDelegate?.updateToProgress(progress: progress.fractionCompleted)
                    
                }
                print("video upload progress update: \(progress.fractionCompleted)")
                
            })
        }
        
        
        self.completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if(error != nil) {
                    DataManager.resetUploadTasks(ids: [Int(task.taskIdentifier)], completionHandler: { (success) in
                        if(self.uploadDelegate != nil) {
                            self.uploadDelegate?.updateToUploads()
                            
                        }
                        self.awakenUploads(context: self.context!)
                        
                    })
                    
                } else {
                    
                    
                }
                
            })
        }
        
        
        videoProcessor.createVideoFile(request: request, completionHandler: {
        (success, url) in
        
            if(success) {
                 self.transferUtility.uploadFile(url!,
                                               key: request.value(forKey: Constants.FIELD_VIDEO_ID) as! String,
                                               contentType: "video/mp4",
                                               expression: self.uploadExpression,
                                               completionHandler: self.completionHandler).continueWith {
                                                    (task) -> AnyObject! in
                                                
                                                    print("starting new uploading")
                                                
                                                    if let error = task.error {
                                                        print("Error: \(error.localizedDescription)")
                                                    }
                                                
                                                    if let _ = task.result {
                                                        
                                                    }
                                                    return nil;
              
                                                }
            }
        })
    
    }



}
    
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
    
    
    

