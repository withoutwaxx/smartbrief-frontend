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
                if(projects.count > 0) {
                    DataManager.saveProjects(projects: projects, count: count)
                    
                }
                
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
        RequestExecutionManager.getVideos(endpoint: buildURL(projectId: projectId), completionHandler: {
            (success, message, videos) in
            
            if(success) {
                if(videos.count > 0) {
                    DataManager.saveVideos(videos: videos)
                    
                }
                
                completionHandler(true, "")
            } else {
                completionHandler(false, message)
                
            }
        })
        
    }
    
    
    static func updateProject( project:NSManagedObject, readyValue:Int, completionHandler: @escaping (_ success: Bool, _ message :String) -> ()){
        let url = "\(Constants.updateProject)?".appending(buildUpdateURL(project: project, readyValue: readyValue))
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
    
    
    
    static func buildUpdateURL (project:NSManagedObject, readyValue:Int) -> String {
        
        let pTitle = project.value(forKeyPath: "project_name") as! String
        let rdState = readyValue
        let rcState = project.value(forKeyPath: "received_state") as! Int
        let pId = project.value(forKeyPath: "project_id") as! String
        
        let url = "pId=\(pId)&rdS=\(rdState)&rcS=\(rcState)&pName=\(pTitle)&".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        return url!
    }
    
    
    
    static func buildURL (projectId:String) -> String {
        return "\(Constants.getVideos)?pid=\(projectId)&"
    }
    
    

}


