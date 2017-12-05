//
//  APIEndPoints.swift
//  todolist
//
//  Created by Tom Rogers on 06/10/2016.
//  Copyright © 2016 WithoutWaxx. All rights reserved.
//

import Foundation


class Constants {

    private static let baseURL = "https://www.smartfile-portal.com/v1"
    
    static let signUpURL = "\(baseURL)/signup"
    static let signInURL = "\(baseURL)/signin"
    static let getProjects = "\(baseURL)/projects"
    static let newProject = "\(baseURL)/projects/new"
    static let getVideos = "\(baseURL)/videos"
    static let newVideo = "\(baseURL)/videos/create"
    static let deleteProject = "\(baseURL)/projects/delete"
    static let updateProject = "\(baseURL)/projects/update"
    
    static let s3BaseURL = "https://s3.eu-west-2.amazonaws.com/finalsmartfilebucket/"
    
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
    
    static let FIELD_UPLOAD_TASK_ID = "task_id"
    static let FIELD_UPLOAD_ACTIVE = "active_state"
    static let FIELD_UPLOAD_UPLOADED_STATE = "uploaded_state"
    static let FIELD_UPLOAD_LOCAL_URL = "local_url"



    

}
