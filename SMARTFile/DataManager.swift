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
    
    static func getDate (stringDate:String) -> Date {
        
        let index = stringDate.index(stringDate.endIndex, offsetBy: -14)
        let shortDate = stringDate.substring(to: index)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: shortDate)!
        return date
    }
    
    static func getCount (id:String, count:[JSON]) -> Int {
        for project in count {
            if(project["project_id"].stringValue == id) {
                return project["count"].intValue
            }
        }
        return 0
    }
    
    static func saveProjects(projects:[JSON], count:[JSON]) {
        
        deleteProjectRecords()
        
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
                    newProject.setValue(getDate(stringDate: oneProject["date_created"].stringValue), forKeyPath: "date_created")
                    newProject.setValue(oneProject["received_state"].boolValue, forKeyPath: "received_state")
                    newProject.setValue(oneProject["ready_state"].boolValue, forKeyPath: "ready_state")
                    newProject.setValue(getCount(id: oneProject["project_id"].stringValue, count: count), forKeyPath: "video_count")
                } else {
                    let existingProject = records[0]
                    existingProject.setValue(oneProject["project_id"].stringValue, forKeyPath: "project_id")
                    existingProject.setValue(oneProject["project_name"].stringValue, forKeyPath: "project_name")
                    existingProject.setValue(getDate(stringDate: oneProject["date_created"].stringValue), forKeyPath: "date_created")
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
        
        deleteVideoRecords()
        
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
                    newVideo.setValue(getDate(stringDate: oneVideo["date_uploaded"].stringValue), forKeyPath: "date_uploaded")
                    newVideo.setValue(oneVideo["video_desc"].stringValue, forKeyPath: "video_desc")
                    newVideo.setValue(oneVideo["size"].intValue, forKeyPath: "size")
                    newVideo.setValue(oneVideo["length"].intValue, forKeyPath: "length")
                    newVideo.setValue(oneVideo["url"].stringValue, forKeyPath: "url")
                } else {
                    let existingVideo = records[0]
                    existingVideo.setValue(oneVideo["video_id"].stringValue, forKeyPath: "video_id")
                    existingVideo.setValue(oneVideo["project_id"].stringValue, forKeyPath: "project_id")
                    existingVideo.setValue(getDate(stringDate: oneVideo["date_uploaded"].stringValue), forKeyPath: "date_uploaded")
                    existingVideo.setValue(oneVideo["video_desc"].stringValue, forKeyPath: "video_desc")
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
    
    
    
    static func saveUploadRequests(uploads:[UploadRequest], completionHandler: @escaping (_ success: Bool) -> ()){
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        for upload in uploads {
            

            let newUpload = NSEntityDescription.insertNewObject(forEntityName: "VideoUpload", into: managedContext) as NSManagedObject
                
            newUpload.setValue( upload.localId , forKeyPath: "local_id")
            newUpload.setValue( upload.videoId , forKeyPath: "video_id")
            newUpload.setValue( upload.projectId , forKeyPath: "project_id")
            newUpload.setValue( upload.taskId , forKeyPath: "task_id")
            newUpload.setValue( upload.userId , forKeyPath: "user_id")
            newUpload.setValue( upload.desc , forKeyPath: "desc")
            newUpload.setValue( upload.url , forKeyPath: "url")
            newUpload.setValue( upload.length , forKeyPath: "length")
            newUpload.setValue( upload.size , forKeyPath: "size")
            newUpload.setValue( upload.uploaded , forKeyPath: "uploaded")
            newUpload.setValue( upload.sent , forKeyPath: "sent")
            
        }
        
        do {
            try managedContext.save()
            completionHandler(true)
        } catch let error as NSError {
            completionHandler(false)
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    
    
    static func deleteAllRecords() {
        deleteVideoRecords()
        deleteProjectRecords()
        
    }

    
    
    static func deleteVideoRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context.execute(request)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    
    static func deleteProjectRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context.execute(request)
            try context.save()
        } catch {
            print ("There was an error")
        }
        
    }
    
}
