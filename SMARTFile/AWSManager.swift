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


class AWSManager {
    
    weak var uploadDelegate:UploadDelegate?
    weak var videoDelegate:NewVideoDelegate?
    weak var uploadProgressDelegate:UploadProgressDelegate?
    
    var transferUtility:AWSS3TransferUtility
    var newRequests:[NSManagedObject] = []
    var requestsToSend:[NSManagedObject] = []
    var activeRequests:[NSManagedObject] = []
    var completionHandler:AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var context:NSManagedObjectContext?
    
    
    
    static let sharedInstance = AWSManager()
    
    
    private init() {
        let credentialProvider = AWSCognitoCredentialsProvider (
            regionType: .EUWest2,
            identityPoolId: "eu-west-2:206e8f66-fe59-44dc-8cf5-2b6038bcf7a5"
        )
        
        let configuration = AWSServiceConfiguration(region: .EUWest2, credentialsProvider: credentialProvider)
        let config:AWSS3TransferUtilityConfiguration = AWSS3TransferUtilityConfiguration()
        config.isAccelerateModeEnabled = true
        config.bucket = Constants.S3_BUCKET
        AWSS3TransferUtility.register(with: configuration!, transferUtilityConfiguration: config, forKey: "UPLOAD_MANAGER")
        transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "UPLOAD_MANAGER")
        
    }
    
    
    func updateRequestLists () {
        let sort = NSSortDescriptor(key: Constants.FIELD_VIDEO_ADDED, ascending: false)
        var predicates:[NSPredicate] = []
        predicates.append(NSPredicate(format: "\(Constants.FIELD_UPLOAD_ACTIVE_STATE) = %@", false as CVarArg))
        predicates.append(NSPredicate(format: "\(Constants.FIELD_UPLOAD_UPLOADED_STATE) = %@", false as CVarArg))
        newRequests = DataManager.getUploadRequests(predicates: predicates, sort: [sort], bg: true, context: context )
        predicates = []
        predicates.append(NSPredicate(format: "\(Constants.FIELD_UPLOAD_ACTIVE_STATE) = %@", true as CVarArg))
        activeRequests = DataManager.getUploadRequests(predicates: predicates, sort: [sort], bg: true, context: context )
        predicates = []
        predicates.append(NSPredicate(format: "\(Constants.FIELD_UPLOAD_UPLOADED_STATE) = %@", true as CVarArg))
        requestsToSend = DataManager.getUploadRequests(predicates: predicates, sort: [sort], bg: true, context: context )
        
        
    }
    
    
    
    func checkForUploadedNotUpdated () {
        
        if(!requestsToSend.isEmpty) {
            RequestDelegate.executeNewVideo(requests: requestsToSend, index: 0, context: context!, completionHandler: {
                (success) in
                if(success) {
                    if(self.videoDelegate != nil) {
                        DispatchQueue.main.async {
                            self.videoDelegate?.updateToVideo()
                        }
                        
                    }
                    
                }
                self.updateRequestLists()
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
            DataManager.resetUploadTasks(ids:incorrectRequests, context: context!, completionHandler: {
                (success) in
                if(self.uploadDelegate != nil) {
                    DispatchQueue.main.async {
                        self.uploadDelegate?.updateToUploads()
                        
                    }
                    
                    
                }
                self.updateRequestLists()
                completionHandler(true)
                
            })
            
        }
        
    }
    
    
    
    func validateActiveUpload(task:AWSS3TransferUtilityUploadTask) {
        
        var currentRequest:NSManagedObject?
        var found = false
        
        for request in newRequests {
            if(request.value(forKey: Constants.FIELD_UPLOAD_TASK_ID) as! Int == Int(task.taskIdentifier)) {
                currentRequest = request
                found = true
                break
                
            }
            
        }
        
        if(found) {
            if(currentRequest?.value(forKey: Constants.FIELD_UPLOAD_ACTIVE_STATE) as! Bool  == false) {
                if(!((currentRequest?.value(forKey: Constants.FIELD_UPLOAD_LOCAL_URL) as! String).isEmpty)) {
                    DataManager.updateSingleUploadTask(findField: Constants.FIELD_VIDEO_ID, findValue: currentRequest?.value(forKey: Constants.FIELD_VIDEO_ID) as! String, updateField: Constants.FIELD_UPLOAD_ACTIVE_STATE, updateValueBool: true, updateValueString: "", updateTypeBool: true, bg: true, context: context!)
                    
                } else {
                    task.cancel()
                    DataManager.resetUploadTasks(ids: [currentRequest?.value(forKey: Constants.FIELD_UPLOAD_TASK_ID) as! Int], context: context!, completionHandler: { (success) in
                        if(self.uploadDelegate != nil) {
                            DispatchQueue.main.async {
                                self.uploadDelegate?.updateToUploads()
                            
                            }
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
                
                self.updateActiveUploads(activeUploads: uploadTasks, completionHandler: {
                    (success) in
                    for upload in uploadTasks {
                        self.validateActiveUpload(task: upload)
                        
                    }
                    
                })
                completionHandler(true)
                
               
                
                return nil
                
            }
            
            return nil
            
        })
        
        updateRequestLists()
        
    }
    
    
    
    func nextSuitableRequest () -> (Bool,NSManagedObject?) {
        for request in newRequests {
            if(request.value(forKey: Constants.FIELD_UPLOAD_UPLOADED_STATE) as! Bool == false ) {
                return (true, request)
                
            }
            
        }
        
        return (false, nil)
        
    }
    
    
    
    func awakenUploads () {
       
        updateRequestLists()
        checkForUploadedNotUpdated()
        updateActive(completionHandler: {
            
        (complete) in
        
            if(self.activeRequests.count == 0) {
                let (proceed, request) = self.nextSuitableRequest()
                
                if(proceed) {
                    //print("should be proceeding")
                    self.startNewUpload(request: request!)
                    
                } else {
                    //print("no next video found")
                    
                    RequestDelegate.getProjects(completionHandler: { (success, message) in
                    })
                    
                    VideoManager.sharedInstance.clearUsersDirectory()
                    
                }
                
            }
            
        })
        
    }
    
    
    func completeUpload (task:Int, status:Bool) {
        
        DispatchQueue.main.async(execute: {
            if(self.uploadProgressDelegate != nil) {
                self.uploadProgressDelegate?.updateToProgress(progress: 0.0)
                
            }
            
        })
        
        var predicates:[NSPredicate] = []
        predicates.append(NSPredicate(format: "task_id = %d", task))
        
        let request = DataManager.getUploadRequests(predicates: predicates, sort: [], bg: true, context: self.context)
        
        if(!request.isEmpty) {
            VideoManager.sharedInstance.deleteVideoFile(localUrl: request.first?.value(forKey: Constants.FIELD_UPLOAD_LOCAL_URL) as! String )
            
            if(status) {
                DataManager.completeUploadTask(request: request[0], context: context!, completionHandler: {
                    (success) in
                    if(success) {
                        
                        RequestDelegate.executeNewVideo(requests: [request.first!], index: 0, context: self.context!, completionHandler: {
                            (success) in
        
                            if(success) {
                                
                                NotificationManager.sharedInstance.notifyUser()
                                
                                if(self.videoDelegate != nil) {
                                    DispatchQueue.main.async {
                                        self.videoDelegate?.updateToVideo()
                                        
                                    }
                                }
                                
                            }
                            if(self.uploadDelegate != nil) {
                                DispatchQueue.main.sync {
                                    self.uploadDelegate?.updateToUploads()
                                    
                                }
                            }
                            
                            
                            DispatchQueue.global(qos: .userInitiated).async {
                                self.updateRequestLists()
                                self.awakenUploads()
                                
                            }
                            
                        })
                        
                    }
                    
                })
                
                
            } else {
                DataManager.resetUploadTasks(ids: [task], context: self.context!, completionHandler: {
                    (success) in
                    if(success) {
                        if(self.uploadDelegate != nil) {
                            DispatchQueue.main.async {
                                self.uploadDelegate?.updateToUploads()
                                
                            }
                        }
                        
                    }
                    if(self.uploadDelegate != nil) {
                        DispatchQueue.main.async {
                            self.uploadDelegate?.updateToUploads()
                            
                        }
                    }
                    
            
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.updateRequestLists()
                        self.awakenUploads()
                        
                    }
                    
                })
                
            }
            
            
        }
        
    }
    
    
    
    func deleteAWSAssets(keys:[String], index:Int, completionHandler: @escaping (_ success: Bool) -> ()) {
        let delReq = AWSS3DeleteObjectRequest()
        delReq?.bucket = Constants.S3_BUCKET
        delReq?.key = keys[index]
        AWSS3.default().deleteObject(delReq!).continueWith {
            (output) -> Any? in
            if(!output.isFaulted) {
                let newIndex = index + 1
                if(newIndex < keys.count) {
                    self.deleteAWSAssets(keys: keys, index: newIndex, completionHandler: {
                        (success) in
                        if(success) {
                            completionHandler(true)
                            
                        } else {
                            completionHandler(false)
                            
                        }
                        
                        
                    })
                    
                }
                
                completionHandler(true)
                
            } else {
                completionHandler(false)
                
            }
            
            return nil
            
        }
        
    }
    
    
    
    func startNewUpload(request:NSManagedObject) {
        
        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        uploadExpression.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
            
            print("video upload progress update: \(progress.fractionCompleted)")
            
            DispatchQueue.main.async(execute: {
                if(self.uploadProgressDelegate != nil) {
                    self.uploadProgressDelegate?.updateToProgress(progress: progress.fractionCompleted)
                    
                }
                print("video upload progress update: \(progress.fractionCompleted)")
                
            })
        }
        

        
        
        self.completionHandler = { (task, error) -> Void in
            
                let taskid = Int(task.taskIdentifier)
            
                if(error != nil) {
        
                    self.completeUpload(task: taskid, status: false)
                    
                } else {
                    
                    self.completeUpload(task: taskid, status: true)
                }
     
        }
        
        
        VideoManager.sharedInstance.createVideoFile(request: request, completionHandler: {
        (success, url, err) in
        
            if(success) {
       
                print("making video is", err)
                
                 self.transferUtility.uploadFile(url!,
                                               key: request.value(forKey: Constants.FIELD_VIDEO_ID) as! String,
                                               contentType: "video/mp4",
                                               expression: uploadExpression,
                                               completionHandler: self.completionHandler).continueOnSuccessWith(block: { (task) -> Any? in
                                                
                                                    print("starting new uploading")
                                                
                                                    if let error = task.error {
                                                        print("starting error is ", error)
                                                        print("Error: \(error.localizedDescription)")
                                                    } else {
                                                        DataManager.setUploadTaskActive(request: request, localUrl: url!, taskId: Int(task.result?.taskIdentifier), context: self.context!)
                                                        if(self.uploadDelegate != nil) {
                                                            DispatchQueue.main.async {
                                                                self.uploadDelegate?.updateToUploads()
                                                                
                                                            }
                                                        }
                                                    }
                                                
                                                    if let _ = task.result {
                                                        
                                                    }
                                                    return nil;
              
                                                })
            
            } else {
                print("unable to create video file")
                print(err)
                
            }
        })
    
    }



}

    
    

