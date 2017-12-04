//
//  StringValidator.swift
//  Snofall-trl
//
//  Created by Tom Rogers on 04/05/2017.
//  Copyright © 2017 WithoutWaxx. All rights reserved.
//

import Foundation
import CoreData


class StringManager {
    
    static func checkEmailPassword (email:String, password:String) -> (Bool, String) {
        
        if validateEmail(email: email) {
            if password.characters.count < 8 {
                return (false, NSLocalizedString("ALERT_PASSWORD_SHORT", comment: ""))
            }
        } else {
            return (false, NSLocalizedString("ALERT_INVALID_EMAIL", comment: ""))
        }
        
        return (true, "")
        
    }
    
    
    
    static func validateEmail (email:String) -> Bool {
        let regex: String = "([^\\s])+@([^\\s])+\\.([^\\s])+"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
        
    }
    
    
    static func stringDateToDate (stringDate:String) -> Date {
        
        let index = stringDate.index(stringDate.endIndex, offsetBy: -14)
        let shortDate = stringDate.substring(to: index)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: shortDate)!
        return date
    }
    
    
    static func removeSpace(str:String) -> String {
        return str.replacingOccurrences(of: " ", with: "%")
    }
    
    
    static func dateToStringDate(date:Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if(date != nil) {
            return dateFormatter.string(from:(date)!)
        }
        return ""
    }
    
    
    static func getTime(seconds:Int) -> String {
        if(seconds > 59) {
            return "\(seconds/60)m \(seconds%60)s"
        }
        return "\(seconds)s"
    }
    
    
    static func buildUpdateProjectURL (project:NSManagedObject, readyValue:Int) -> String {
        
        let pTitle = project.value(forKeyPath: "project_name") as! String
        let rdState = readyValue
        let rcState = project.value(forKeyPath: "received_state") as! Int
        let pId = project.value(forKeyPath: "project_id") as! String
        
        let url = "pId=\(pId)&rdS=\(rdState)&rcS=\(rcState)&pName=\(pTitle)&".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        return url!
    }
    
    
    static func buildNewVideoURL (request:NSManagedObject) -> String {
        
        let pVideoId = request.value(forKeyPath: Constants.FIELD_VIDEO_ID) as! String
        let projectId = request.value(forKeyPath: Constants.FIELD_VIDEO_ID) as! String
        let desc = request.value(forKeyPath: Constants.FIELD_VIDEO_ID) as! String
        let size = request.value(forKeyPath: Constants.FIELD_VIDEO_SIZE) as! String
        let length = request.value(forKeyPath: Constants.FIELD_VIDEO_LENGTH) as! String
        let url = request.value(forKeyPath: Constants.FIELD_VIDEO_URL) as! String


        
        let fullUrl = "pVId=\(pVideoId)&pPId=\(projectId)&pDesc=\(desc)&pSize=\(size)&pLength=\(length)&pUrl=\(url)&".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        return fullUrl!
    }
    
    
    
    static func buildGetVideosURL (projectId:String) -> String {
        return "\(Constants.getVideos)?pid=\(projectId)&"
    }
    
}
