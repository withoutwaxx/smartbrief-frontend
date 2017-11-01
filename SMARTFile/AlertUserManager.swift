//
//  AlertUserManager.swift
//  Snofall-trl
//
//  Created by Tom Rogers on 30/01/2017.
//  Copyright © 2017 WithoutWaxx. All rights reserved.
//

import Foundation
import UIKit


class AlertUserManager {
    
    static func displayInfoToUser(title:String, message:String, currentViewController:UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            
        }
        alertController.addAction(okAction)
        currentViewController.present(alertController, animated: true, completion: nil)
        
    }
    
}
