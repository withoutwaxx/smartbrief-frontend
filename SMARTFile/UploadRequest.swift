//
//  UploadRequest.swift
//  SMARTFile
//
//  Created by Tom Rogers on 27/11/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation


class UploadRequest {
    
    var videoId, userId, projectId, localId, desc, url, localUrl:String
    var length, size, taskId:Int
    var added:Date
    var uploadedState, activeState:Bool
    
    init (videoId:String, userId:String, projectId:String, taskId:Int, localId:String, desc:String, url:String, length:Int, size:Int, added:Date, uploadedState:Bool, activeState:Bool, localUrl:String) {
        
        self.videoId = videoId
        self.userId = userId
        self.projectId = projectId
        self.taskId = taskId
        self.localId = localId
        self.desc = desc
        self.url = url
        self.length = length
        self.size = size
        self.added = added
        self.uploadedState = uploadedState
        self.activeState = activeState
        self.localUrl = localUrl
        
    }
    
    
}
