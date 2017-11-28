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
    static let deleteProject = "\(baseURL)/projects/delete"
    static let updateProject = "\(baseURL)/projects/update"
    
    static let s3BaseURL = "https://s3.eu-west-2.amazonaws.com/finalsmartfilebucket/"
    
    

}
