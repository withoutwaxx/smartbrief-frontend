//
//  StringValidator.swift
//  Snofall-trl
//
//  Created by Tom Rogers on 04/05/2017.
//  Copyright © 2017 WithoutWaxx. All rights reserved.
//

import Foundation


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
    
    
    static func dateToString (date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
        
    }
    
    
    static func removeSpace(str:String) -> String {
        return str.replacingOccurrences(of: " ", with: "%")
    }
    
    
    static func getDate(date:Date?) -> String {
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
    
}
