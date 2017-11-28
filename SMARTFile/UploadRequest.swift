//
//  UploadRequest.swift
//  SMARTFile
//
//  Created by Tom Rogers on 27/11/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation


class UploadRequest {
    
    var videoId, userId, projectId, taskId, localId, desc, url:String
    var length, size:Int
    var uploaded:Date
    var sent, active:Bool
    
    init (videoId:String, userId:String, projectId:String, taskId:String, localId:String, desc:String, url:String, length:Int, size:Int, uploaded:Date, sent:Bool, active:Bool) {
        
        self.videoId = videoId
        self.userId = userId
        self.projectId = projectId
        self.taskId = taskId
        self.localId = localId
        self.desc = desc
        self.url = url
        self.length = length
        self.size = size
        self.uploaded = uploaded
        self.sent = sent
        self.active = active
        
    }
    
    
}
