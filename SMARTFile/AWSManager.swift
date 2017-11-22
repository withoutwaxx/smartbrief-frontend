//
//  uploadManager.swift
//  SMARTFile
//
//  Created by Tom Rogers on 18/11/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation
import AWSS3


class AWSManager {
    
    
    
    static func uploadVideo(url:URL, completion:@escaping AWSS3TransferUtilityUploadCompletionHandlerBlock) {
        
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
        let  transferUtility = AWSS3TransferUtility.default()
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
    
    
}
