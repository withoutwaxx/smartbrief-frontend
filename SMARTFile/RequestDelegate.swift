//
//  RequestDelegate.swift
//  Snofall-trl
//
//  Created by Tom Rogers on 23/01/2017.
//  Copyright © 2017 WithoutWaxx. All rights reserved.
//

import Foundation
import CoreData

class RequestDelegate {
    
    

    static func signIn(email:String, password: String, completionHandler: @escaping (_ success: Bool, _ message :String) -> ()){
        RequestExecutionManager.postCredentials(endpoint: Constants.signInURL, email:email, password:password, completionHandler: {
            (success, message) in
            
            if(success) {
                completionHandler(true, "")
            
            } else {
                completionHandler(false, message)

            }
        })
        
    }
    
    static func getProjects( completionHandler: @escaping (_ success: Bool, _ message :String) -> ()){
        RequestExecutionManager.projectRequest(endpoint: Constants.getProjects, completionHandler: {
            (success, message, projects, count) in
            
            if(success) {
                if(projects.count > 0) {
                    DataManager.saveProjects(projects: projects, count: count)
                    
                }
                
                completionHandler(true, "")
            } else {
                completionHandler(false, message)
                
            }
        })
        
    }
    
    
    
    static func newProject( projectTitle:String, completionHandler: @escaping (_ success: Bool, _ message :String) -> ()){
        let url = "\(Constants.newProject)?pt=\(projectTitle.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? "")&"
        RequestExecutionManager.projectRequest(endpoint: url, completionHandler: {
            (success, message, projects, count) in
            if(success) {
                DataManager.saveProjects(projects: projects, count: count)
                completionHandler(true, "")
            
            } else {
                completionHandler(false, message)
                
            }
        })
        
    }
    
    
    static func deleteProject( projectId:String, completionHandler: @escaping (_ success: Bool, _ message :String) -> ()){
        let url = "\(Constants.deleteProject)?pid=\(projectId)&"
        RequestExecutionManager.projectRequest(endpoint: url, completionHandler: {
            (success, message, projects, count) in
            if(success) {
                DataManager.saveProjects(projects: projects, count: count)
                completionHandler(true, "")
                
            } else {
                completionHandler(false, message)
                
            }
        })
        
    }
    
    
    static func getVideos( projectId:String, completionHandler: @escaping (_ success: Bool, _ message :String) -> ()){
        RequestExecutionManager.getVideos(endpoint: StringManager.buildGetVideosURL(projectId: projectId), completionHandler: {
            (success, message, videos) in
            
            if(success) {
                DataManager.saveVideos(videos: videos)
                completionHandler(true, "")
                
            } else {
                completionHandler(false, message)
                
            }
        })
        
    }
    
    
    static func updateProject( project:NSManagedObject, readyValue:Int, completionHandler: @escaping (_ success: Bool, _ message :String) -> ()){
        let url = "\(Constants.updateProject)?".appending(StringManager.buildUpdateProjectURL(project: project, readyValue: readyValue))
        RequestExecutionManager.projectRequest(endpoint: url, completionHandler: {
            (success, message, projects, count) in
            if(success) {
                DataManager.saveProjects(projects: projects, count: count)
                completionHandler(true, "")
                
            } else {
                completionHandler(false, message)
                
            }
        })
        
    }
    
    
    
    
    static func executeNewVideo (requests:[NSManagedObject], index:Int, context:NSManagedObjectContext, completionHandler: @escaping (_ success: Bool) -> ()){
        
        let url = "\(Constants.newVideo)?".appending(StringManager.buildNewVideoURL(request: requests[index]))
        
        RequestExecutionManager.newVideo(endpoint: url, completionHandler: {
            (success) in
            if(success) {
                DataManager.deleteMultiple(ids: [requests[index].value(forKey: Constants.FIELD_VIDEO_ID) as! String], field: Constants.FIELD_VIDEO_ID, entity: Constants.ENTITY_UPLOAD_REQUEST, context: context)
                
            }
            
            let newIndex = index + 1
            if(newIndex < requests.count) {
                executeNewVideo(requests: requests, index: newIndex, context: context, completionHandler: { (success) in
                    if(success){
                        completionHandler(true)
                    }
                    
                })
                
            } else {
                completionHandler(true)
                
            }
        })
        
    }
    
    
    
    static func newVideos(requests:[NSManagedObject], completionHandler: @escaping (_ success: Bool) -> ()){
        
        executeNewVideo(requests: requests, index: 0, completionHandler: { (
            success) in
            
            completionHandler(true)
        
            
        })

    }
    
    
    
    
    
    

}


