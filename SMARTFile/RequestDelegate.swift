//
//  RequestDelegate.swift
//  Snofall-trl
//
//  Created by Tom Rogers on 23/01/2017.
//  Copyright © 2017 WithoutWaxx. All rights reserved.
//

import Foundation


class RequestDelegate {
    

    static func signIn(email:String, password: String, completionHandler: @escaping (_ success: Bool, _ message :String) -> ()){
        RequestExecutionManager.postCredentials(endpoint: APIEndPoints.signInURL, email:email, password:password, completionHandler: {
            (success, message) in
            
            if(success) {
                completionHandler(true, "")
            } else {
                completionHandler(false, message)

            }
        })
        
    }
    
    static func getProjects( completionHandler: @escaping (_ success: Bool, _ message :String) -> ()){
        RequestExecutionManager.getProjects(endpoint: APIEndPoints.getProjects, completionHandler: {
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
    
    
    

}


