//
//  APIEndPoints.swift
//  todolist
//
//  Created by Tom Rogers on 06/10/2016.
//  Copyright © 2016 WithoutWaxx. All rights reserved.
//

import Foundation


class Constants {

    private static let baseURL = "https://www.smartfile-portal.com:443/v1"
    
    static let signUpURL = "\(baseURL)/signup"
    static let signInURL = "\(baseURL)/signin"
    static let updatePasswordURL = "\(baseURL)/update"
    
    static let SMARTFILE_HOME_URL = "http://www.smartphoneproductions.co.uk"
    
    static let THREAD_ID = "com.smartfile.upload"
    
    static let TOKEN = "token"
    static let USER_ID = "userId"
    
    static let getVideos = "\(baseURL)/videos"
    static let newVideo = "\(baseURL)/videos/create"
    static let deleteVideo = "\(baseURL)/videos/delete"
    static let updateVideo = "\(baseURL)/videos/update"
    
    static let deleteProject = "\(baseURL)/projects/delete"
    static let updateProject = "\(baseURL)/projects/update"
    static let getProjects = "\(baseURL)/projects"
    static let newProject = "\(baseURL)/projects/new"
    
    static let S3_BASE_URL = "https://s3.eu-west-2.amazonaws.com/finalsmartfilebucket/"
    static let S3_BUCKET = "finalsmartfilebucket"
    
    static let ENTITY_VIDEO = "Video"
    static let ENTITY_PROJECT = "Project"
    static let ENTITY_UPLOAD_REQUEST = "UploadRequestObj"
    static let FIELD_VIDEO_ID = "video_id"
    static let FIELD_PROJECT_ID = "project_id"
    static let FIELD_VIDEO_DESC = "desc"
    static let FIELD_VIDEO_UPLOADED = "uploaded"
    static let FIELD_VIDEO_SIZE = "size"
    static let FIELD_VIDEO_LENGTH = "length"
    static let FIELD_VIDEO_URL = "url"
    static let FIELD_VIDEO_ADDED = "added"
    
    static let FIELD_PROJECT_READY = "ready_state"
    static let FIELD_USER_ID = "user_id"
    static let FIELD_NOTIFY_STATUS = "notify_status"
    
    static let FIELD_UPLOAD_TASK_ID = "task_id"
    static let FIELD_UPLOAD_ACTIVE_STATE = "active_state"
    static let FIELD_UPLOAD_UPLOADED_STATE = "uploaded_state"
    static let FIELD_UPLOAD_LOCAL_URL = "local_url"
    static let FIELD_UPLOAD_LOCAL_ID = "local_id"




    

}
