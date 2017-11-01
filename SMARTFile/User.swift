//
//  User.swift
//  SMARTFile
//
//  Created by Tom Rogers on 26/10/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation

class User {
    
    static var id:String {
        get {
            return UserDefaults.standard.value(forKey: "userId") as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "userId")
        }
    }
    
    static var token:String {
        get {
            return UserDefaults.standard.value(forKey: "token") as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "token")
        }
    }
    
}
