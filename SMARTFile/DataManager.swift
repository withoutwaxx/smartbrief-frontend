                                                                                                                                             //
//  DataManager.swift
//  SMARTFile
//
//  Created by Tom Rogers on 01/11/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwiftyJSON
import Photos


class DataManager {
    
    
    static func getCount (id:String, count:[JSON]) -> Int {
        for project in count {
            if(project["project_id"].stringValue == id) {
                return project["count"].intValue
            }
        }
        return 0
    }
    
    
    static func completeUploadTask (request:NSManagedObject, context:NSManagedObjectContext, completionHandler: @escaping (_ success: Bool) -> ()) {
        
        
        context.performAndWait {
            
            request.setValue(false, forKey: Constants.FIELD_UPLOAD_ACTIVE_STATE)
            request.setValue(true, forKey: Constants.FIELD_UPLOAD_UPLOADED_STATE)
            let url = request.value(forKey: Constants.FIELD_UPLOAD_LOCAL_URL) as! String
            if(!url.isEmpty) {
                VideoManager.sharedInstance.deleteVideoFile(localUrl: url)
                print("deleted video file")
                
                
            }
        
            do {
                try context.save()
                completionHandler(true)
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                completionHandler(false)
                
            }
                
        }
        
    }
    
    
    static func updateSingleUploadTask (findField:String, findValue:String, updateField:String, updateValueBool:Bool, updateValueString:String, updateTypeBool:Bool, bg:Bool, context:NSManagedObjectContext?) {
       
        

        var predicates:[NSPredicate] = []
        predicates.append(NSPredicate(format: "\(findField) = %@", findValue))
        
        var uploadRequest:[NSManagedObject] = []
        
        if(bg) {
            uploadRequest = DataManager.getUploadRequests(predicates: predicates, sort: [], bg: true, context: context)
            
            
            if(!uploadRequest.isEmpty) {
                context?.performAndWait {
                    
                    if(updateTypeBool) {
                        uploadRequest[0].setValue(updateValueBool, forKey: updateField)
                        
                    } else {
                        uploadRequest[0].setValue(updateValueString, forKey: updateField)
                        
                    }
                    
                    do {
                        try context?.save()
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                        
                    }
                    
                }
                
            }
        } else {
            uploadRequest = DataManager.getUploadRequests(predicates: predicates, sort: [], bg: false, context: nil)
            
            if(!uploadRequest.isEmpty) {
                guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                        return
                }
                
                let managedContext =
                    appDelegate.persistentContainer.viewContext
                
                if(updateTypeBool) {
                    uploadRequest[0].setValue(updateValueBool, forKey: updateField)
                    
                } else {
                    uploadRequest[0].setValue(updateValueString, forKey: updateField)
                    
                }
                
                if (managedContext.hasChanges) {
                    do {
                        try managedContext.save()
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    static func setUploadTaskActive(request:NSManagedObject, localUrl:URL, taskId:Int, context: NSManagedObjectContext ){
        
        
        var predicates:[NSPredicate] = []
        predicates.append(NSPredicate(format: "video_id = %@", request.value(forKey: Constants.FIELD_VIDEO_ID) as! String))
        
        let uploadRequest = DataManager.getUploadRequests(predicates: predicates, sort: [], bg: true, context: context)
        
        if(!uploadRequest.isEmpty) {
            context.performAndWait {
                uploadRequest[0].setValue(true, forKey: Constants.FIELD_UPLOAD_ACTIVE_STATE)
                uploadRequest[0].setValue(taskId, forKey: Constants.FIELD_UPLOAD_TASK_ID)
                uploadRequest[0].setValue(localUrl.path, forKey: Constants.FIELD_UPLOAD_LOCAL_URL)
                
                do {
                    try context.save()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    
                }
                
            }

        }
        
    }
    
    
    
    static func resetUploadTasks(ids:[Int], context:NSManagedObjectContext, completionHandler: @escaping (_ success: Bool) -> ()){
        
        
        context.performAndWait {
            
            for id in ids {
                
                var predicates:[NSPredicate] = []
                predicates.append(NSPredicate(format: "task_id = %d", id))
                
                let uploadRequest = DataManager.getUploadRequests(predicates: predicates, sort: [], bg: true, context: context)
                
                if(!uploadRequest.isEmpty) {
                    uploadRequest[0].setValue(false, forKey: Constants.FIELD_UPLOAD_ACTIVE_STATE)
                    uploadRequest[0].setValue(-1, forKey: Constants.FIELD_UPLOAD_TASK_ID)
                    let url = uploadRequest[0].value(forKey: Constants.FIELD_UPLOAD_LOCAL_URL) as! String
                    if(!url.isEmpty) {
                        VideoManager.sharedInstance.deleteVideoFile(localUrl: url)
                        print("deleted video file")
                        uploadRequest[0].setValue("", forKey: Constants.FIELD_UPLOAD_LOCAL_URL)
                        
                    }
                    
                }
                
            }

            do {
                try context.save()
                completionHandler(true)
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                completionHandler(false)
                
            }
            
        }
        
    }

    
    
    static func saveProjects(projects:[JSON], count:[JSON]) {
        
        deleteAllOfType(type: "Project")
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        for oneProject in projects {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
            
            let predicate = NSPredicate(format: "project_id == %@", oneProject["project_id"].stringValue)
            fetchRequest.predicate = predicate
            
            do {
                let records = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
                if records.count == 0 {
                    let newProject = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedContext) as NSManagedObject
                    
                    newProject.setValue(oneProject["project_id"].stringValue, forKeyPath: "project_id")
                    newProject.setValue(oneProject["project_name"].stringValue, forKeyPath: "project_name")
                    newProject.setValue(StringManager.stringDateToDate(stringDate: oneProject["date_created"].stringValue), forKeyPath: "date_created")
                    newProject.setValue(oneProject["received_state"].boolValue, forKeyPath: "received_state")
                    newProject.setValue(oneProject["ready_state"].boolValue, forKeyPath: "ready_state")
                    newProject.setValue(getCount(id: oneProject["project_id"].stringValue, count: count), forKeyPath: "video_count")
                } else {
                    let existingProject = records[0]
                    existingProject.setValue(oneProject["project_id"].stringValue, forKeyPath: "project_id")
                    existingProject.setValue(oneProject["project_name"].stringValue, forKeyPath: "project_name")
                    existingProject.setValue(StringManager.stringDateToDate(stringDate: oneProject["date_created"].stringValue), forKeyPath: "date_created")
                    existingProject.setValue(oneProject["received_state"].boolValue, forKeyPath: "received_state")
                    existingProject.setValue(oneProject["ready_state"].boolValue, forKeyPath: "ready_state")
                    existingProject.setValue(getCount(id: oneProject["project_id"].stringValue, count: count), forKeyPath: "video_count")
                }
                
            } catch {
                print(error)
            }
        
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
       
    }
    
    
    
    static func saveVideos(videos:[JSON]) {
        
        deleteAllOfType(type: "Video")
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        for oneVideo in videos {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
            
            let predicate = NSPredicate(format: "video_id == %@", oneVideo["video_id"].stringValue)
            fetchRequest.predicate = predicate
            
            do {
                let records = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
                if records.count == 0 {
                    let newVideo = NSEntityDescription.insertNewObject(forEntityName: "Video", into: managedContext) as NSManagedObject
                    
                    newVideo.setValue(oneVideo["video_id"].stringValue, forKeyPath: "video_id")
                    newVideo.setValue(oneVideo["project_id"].stringValue, forKeyPath: "project_id")
                    newVideo.setValue(StringManager.stringDateToDate(stringDate: oneVideo["uploaded"].stringValue), forKeyPath: "uploaded")
                    
                    newVideo.setValue(oneVideo["description"].stringValue, forKeyPath: "desc")
                    newVideo.setValue(oneVideo["size"].intValue, forKeyPath: "size")
                    newVideo.setValue(oneVideo["length"].intValue, forKeyPath: "length")
                    newVideo.setValue(oneVideo["url"].stringValue, forKeyPath: "url")
                } else {
                    let existingVideo = records[0]
                    existingVideo.setValue(oneVideo["video_id"].stringValue, forKeyPath: "video_id")
                    existingVideo.setValue(oneVideo["project_id"].stringValue, forKeyPath: "project_id")
                    existingVideo.setValue(StringManager.stringDateToDate(stringDate: oneVideo["uploaded"].stringValue), forKeyPath: "uploaded")
                    existingVideo.setValue(oneVideo["desc"].stringValue, forKeyPath: "desc")
                    existingVideo.setValue(oneVideo["size"].intValue, forKeyPath: "size")
                    existingVideo.setValue(oneVideo["length"].intValue, forKeyPath: "length")
                    existingVideo.setValue(oneVideo["url"].stringValue, forKeyPath: "url")
                }
                
            } catch {
                print(error)
            }
            
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    
    
    static func saveUploadRequests(uploads:[UploadRequest], completionHandler: @escaping (_ success: Bool, _ duplicate:Bool) -> ()){
        
        var duplicateFound = false
        var records:[NSManagedObject] = []
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        for upload in uploads {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UploadRequestObj")
            
            let localIdPredicate = NSPredicate(format: "local_id = %@", upload.localId)
            let projectIdPredicate = NSPredicate(format: "project_id = %@", upload.projectId)
            
            let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [localIdPredicate, projectIdPredicate])
            
            fetchRequest.predicate = andPredicate
            
            do {
                records = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            } catch let error as NSError {
                completionHandler(false, duplicateFound)
                print("Could not save. \(error), \(error.userInfo)")
            }
            if records.count > 0 {
                duplicateFound = true
            
            } else {
                let newUpload = NSEntityDescription.insertNewObject(forEntityName: "UploadRequestObj", into: managedContext) as NSManagedObject
                
                newUpload.setValue( upload.localId , forKeyPath: "local_id")
                newUpload.setValue( upload.videoId , forKeyPath: "video_id")
                newUpload.setValue( upload.projectId , forKeyPath: "project_id")
                newUpload.setValue( upload.taskId , forKeyPath: "task_id")
                newUpload.setValue( upload.userId , forKeyPath: "user_id")
                newUpload.setValue( upload.desc , forKeyPath: "desc")
                newUpload.setValue( upload.url , forKeyPath: "url")
                newUpload.setValue( upload.length , forKeyPath: "length")
                newUpload.setValue( upload.size , forKeyPath: "size")
                newUpload.setValue( upload.added , forKeyPath: "added")
                newUpload.setValue( upload.uploadedState , forKeyPath: "uploaded_state")
                newUpload.setValue( upload.activeState, forKey: "active_state")
                newUpload.setValue( upload.localUrl, forKey: "local_url")
                
            }
    
        }
        
        do {
            try managedContext.save()
            completionHandler(true, duplicateFound)
        } catch let error as NSError {
            completionHandler(false, duplicateFound)
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    
    
    static func deleteAllRecords() {
        deleteAllOfType(type: "Video")
        deleteAllOfType(type: "Project")
        
    }

    
    
    static func deleteAllOfType(type:String) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: type)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context.execute(request)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    
    static func deleteMultiple (ids:[String], field:String, entity:String, bg:Bool, context:NSManagedObjectContext?) {
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        if(bg) {
            context?.performAndWait {
                do {
                    let records = try context?.fetch(fetchRequest) as! [NSManagedObject]
                    if records.count > 0 {
                        for record in records {
                            if(ids.contains(record.value(forKey: field) as! String) ) {
                                context?.delete(record)
                                
                            }
                            
                        }
                        
                    }
                    
                } catch {
                    print(error)
                }
                
                do {
                    try context?.save()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    
                }
                
            }
            
        } else {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            do {
                let records = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
                if records.count > 0 {
                    for record in records {
                        if(ids.contains(record.value(forKey: field) as! String) ) {
                            managedContext.delete(record)
                            
                        }
                        
                    }
                    
                }
                
            } catch {
                print(error)
            }
            
            do {
                try managedContext.save()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                
            }
            
        }
        
    }
    
    
    
    static func getUploadRequestsWithCompletion (predicates:[NSPredicate], sort:[NSSortDescriptor], context:NSManagedObjectContext?, completionHandler: @escaping (_ requestQueue:[NSManagedObject]) -> ()) {

        var requestQueue:[NSManagedObject]?
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UploadRequestObj")
        
        if(sort.count > 0) {
            fetchRequest.sortDescriptors = sort
            
        }
        
        if(predicates.count > 1) {
            let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
            fetchRequest.predicate = andPredicate
            
        }
        
        if(predicates.count == 1) {
            fetchRequest.predicate = predicates[0]
            
        }
        
       
        context?.performAndWait {
            do {
                requestQueue = try context?.fetch(fetchRequest) as? [NSManagedObject]
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                
            }
            
            completionHandler(requestQueue!)
            
        }
        
    }
    
    
    static func getUploadRequests (predicates:[NSPredicate], sort:[NSSortDescriptor], bg:Bool, context:NSManagedObjectContext?) -> [NSManagedObject] {
        let managedContext:NSManagedObjectContext
        var requestQueue:[NSManagedObject]?
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UploadRequestObj")
        
        if(sort.count > 0) {
            fetchRequest.sortDescriptors = sort
            
        }
        
        if(predicates.count > 1) {
            let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates)
            fetchRequest.predicate = andPredicate
            
        }
        
        if(predicates.count == 1) {
            fetchRequest.predicate = predicates[0]
            
        }
        
        if(bg) {
            context?.performAndWait {
                do {
                    requestQueue = try context?.fetch(fetchRequest) as? [NSManagedObject]
                
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                
                }
            }
            
            if let checkRequests = requestQueue {
                return checkRequests
                
            } else {
                return []
                
            }
            
        }
        
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        do {
            requestQueue = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
          
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
           
        }
        
        if let checkRequests = requestQueue {
            return checkRequests
            
        } else {
            return []
            
        }
        
        
    }
    
    
    
    static func getVideos (predicates:[NSPredicate], sort:[NSSortDescriptor]) -> [NSManagedObject] {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        
        if(predicates.count > 0) {
            fetchRequest.predicate = predicates[0]
        
        }
        
        if(sort.count > 0) {
            fetchRequest.sortDescriptors = sort
        
        }
        
        do {
            let videos = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            return videos
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
        
    }
    
    
    static func getProjects (id:String?) -> [NSManagedObject] {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Project")
        
        let sort = NSSortDescriptor(key: "date_created", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        
        if let findId = id {
            let localIdPredicate = NSPredicate(format: "\(Constants.FIELD_PROJECT_ID) = %@", findId)
            fetchRequest.predicate = localIdPredicate
            
        }
        
        do {
            let projects = try managedContext.fetch(fetchRequest)
            return projects
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
        
    }
    
    
    
    static func initialiseUserNotifications () {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
        let user:[NSManagedObject]

        fetchRequest.predicate = NSPredicate(format: "\(Constants.FIELD_USER_ID) = %@", User.id)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        do {
            user = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return
            
        }
        
        if(user.isEmpty) {
            
            let newUser = NSEntityDescription.insertNewObject(forEntityName: "Notifications", into: managedContext) as NSManagedObject
            
            newUser.setValue(true, forKey: Constants.FIELD_NOTIFY_STATUS)
            newUser.setValue(User.id, forKey: Constants.FIELD_USER_ID)
            
            do {
                try managedContext.save()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                
            }
            
        }
    
    }
    
    
    
    static func updateUserNotifications (value:Bool) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
        let user:[NSManagedObject]
        
        fetchRequest.predicate = NSPredicate(format: "\(Constants.FIELD_USER_ID) = %@", User.id)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        do {
            user = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return
            
        }
        
        if(!user.isEmpty) {
            
            user[0].setValue(value, forKey: Constants.FIELD_NOTIFY_STATUS)
            
            do {
                try managedContext.save()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                
            }
            
        }
        
    }
    
    
    
    static func getUserNotifications (context:NSManagedObjectContext) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
        var user:[NSManagedObject] = []
        
        fetchRequest.predicate = NSPredicate(format: "\(Constants.FIELD_USER_ID) = %@", User.id)
        
       
        context.performAndWait {
            do {
                user = try context.fetch(fetchRequest) as! [NSManagedObject]
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                
            }
            
        }
        
        if(!user.isEmpty) {
            
            if(user[0].value(forKey: Constants.FIELD_NOTIFY_STATUS) as! Bool) {
                return true
                
            }
            
        }
        
        return false
        
    }
    
    
    
    
    static func objectsToKeys(objects:[NSManagedObject]) -> [String] {
        var keys:[String] = []
        for object in objects {
            keys.append(object.value(forKey: Constants.FIELD_VIDEO_ID) as! String)
            
        }
        
        return keys
        
    }
    
}
