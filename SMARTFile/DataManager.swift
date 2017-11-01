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
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        
        for oneProject in projects {
            
            let newProject = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedContext) as NSManagedObject

            newProject.setValue(oneProject["project_id"].stringValue, forKeyPath: "project_id")
            newProject.setValue(oneProject["project_name"].stringValue, forKeyPath: "project_name")
            newProject.setValue(getDate(stringDate: oneProject["date_created"].stringValue), forKeyPath: "date_created")
            newProject.setValue(oneProject["received_state"].boolValue, forKeyPath: "received_state")
            newProject.setValue(oneProject["ready_state"].boolValue, forKeyPath: "ready_state")
            newProject.setValue(getCount(id: oneProject["project_id"].stringValue, count: count), forKeyPath: "video_count")
            
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
       
        
    
        
    }
    
}
