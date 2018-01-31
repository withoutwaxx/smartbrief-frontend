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
    
    
    static func getInfoFromUser(title:String, message:String, finishedAction:String, placeholder:String, currentViewController:UIViewController, completionHandler: @escaping (_ success: Bool, _ userText :String) -> ()){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert )
        let okAction = UIAlertAction(title: finishedAction, style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            completionHandler(true, (alertController.textFields?[0].text)!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            completionHandler(false, "")
            
        }
                
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = placeholder
            
        })
        currentViewController.present(alertController, animated: true, completion: nil)
        
    }
    
    
    static func warnUser( action: String, message:String, currentViewController:UIViewController, completionHandler: @escaping (_ success: Bool) -> ()){
        let alertController = UIAlertController(title: NSLocalizedString("ALERT_TITLE_WARNING", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let deleteAction = UIAlertAction(title: action, style: UIAlertActionStyle.destructive ) { (result : UIAlertAction) -> Void in
            completionHandler(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            completionHandler(false)
            
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
   
        currentViewController.present(alertController, animated: true, completion: nil)
        
    }
    
}
