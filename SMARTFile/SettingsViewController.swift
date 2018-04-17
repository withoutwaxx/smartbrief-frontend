//
//  SettingsViewController.swift
//  SMARTFile
//
//  Created by Tom Rogers on 25/10/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var newPassRepeatField: UITextField!
    @IBOutlet weak var oldPassTextField: UITextField!
    
    @IBOutlet weak var newPassTextField: UITextField!
    
    @IBOutlet weak var notificationsSwitch: UISwitch!

    
    
    
    @IBAction func notificationsSwitchPressed(_ sender: Any) {
        if(notificationsSwitch.isOn) {
            DataManager.updateUserNotifications(value: true)
            
        } else {
            DataManager.updateUserNotifications(value: false)
            
        }
        
        updateView()
        
    }
    
    
    
    @IBAction func changePasswordPressed(_ sender: Any) {
        if let oldPassword = oldPassTextField.text {
            if let newPassword = newPassTextField.text {
                if let newPasswordRepeat = newPassRepeatField.text {
                    let result = StringManager.verifyPasswordChange(oldPassword: oldPassword, newPassword: newPassword, newRepeatPassword: newPasswordRepeat)
                    
                    if(result.0) {
                        RequestDelegate.changePassword(oldPasswordParam: oldPassword, newPasswordParam: newPassword, completionHandler: {
                            
                            (success, message) in
                            
                            if(success) {
                                AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_SUCCESS", comment: ""), message: NSLocalizedString("ALERT_PASSWORD_CHANGED", comment: ""), currentViewController: self)
                                self.oldPassTextField.text = ""
                                self.newPassTextField.text = ""
                                self.newPassRepeatField.text = ""
                                
                            } else {
                                AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: message , currentViewController: self)
                                
                            }
                            
                        
                        })
                        
                    } else {
                        AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: result.1 , currentViewController: self)
                        
                    }
                
                }
            
            }
            
        }
        
        
        
        
    }
    
    
    
    
    
    func updateView () {
        if(DataManager.getUserNotifications(context: AWSManager.sharedInstance.context!)) {
            notificationsSwitch.setOn(true, animated: true)
            
        } else {
            notificationsSwitch.setOn(false, animated: true)
            
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oldPassTextField.delegate = self
        newPassTextField.delegate = self
        newPassRepeatField.delegate = self
        
        oldPassTextField.attributedPlaceholder = NSAttributedString(string: "Current Password", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        newPassTextField.attributedPlaceholder = NSAttributedString(string: "New Password", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        newPassRepeatField.attributedPlaceholder = NSAttributedString(string: "Repeat New Password", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        
        updateView()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        User.token = ""
        User.id = ""
        performSegue(withIdentifier: "showLogin", sender: self)
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
