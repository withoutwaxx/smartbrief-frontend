//
//  User.swift
//  SMARTFile
//
//  Created by Tom Rogers on 26/10/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class User {
    
    static var id:String {
        get {
            return UserDefaults.standard.value(forKey: Constants.USER_ID) as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.USER_ID)
        }
    }
    
    static var token:String {
        get {
            if let retrievedString: String = KeychainWrapper.standard.string(forKey: Constants.TOKEN) {
                return retrievedString
            }
            return ""
            
        }
        set {
            KeychainWrapper.standard.set(newValue, forKey: Constants.TOKEN)
        }
    }
    
}
