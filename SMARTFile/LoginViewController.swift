//
//  ViewController.swift
//  SMARTFile
//
//  Created by Tom Rogers on 25/10/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginText: UILabel!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailText.delegate = self
        self.passwordText.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginPressed(_ sender: Any) {
        if let email = emailText.text, !email.isEmpty {
            if let password = passwordText.text, !password.isEmpty {
                let (valid, msg) = StringManager.checkEmailPassword(email: email, password: password)
                if(valid) {
                    loginText.layer.isHidden = false
                    RequestDelegate.signIn(email: email, password: password, completionHandler: { (success, message) in
                        if(success) {
                            self.loginText.text = "Getting projects.."
                            RequestDelegate.getProjects(completionHandler: { (success, message) in
                                if(success) {
                                    self.performSegue(withIdentifier: "showProjects", sender: self)
                                    
                                } else {
                                    self.loginText.layer.isHidden = true
                                    AlertUserManager.displayInfoToUser(title: "Oops", message: message, currentViewController: self)
                                }
                            })
                                
                        } else {
                            self.loginText.layer.isHidden = true
                            AlertUserManager.displayInfoToUser(title: "Oops", message: message, currentViewController: self)
                        }
                    })
                } else {
                    
                    AlertUserManager.displayInfoToUser(title: "Oops", message: msg, currentViewController: self)

                }
            
            } else {
                AlertUserManager.displayInfoToUser(title: "Oops", message: NSLocalizedString("ALERT_EMPTY_PASSWORD", comment: ""), currentViewController: self)
            }
        } else {
            AlertUserManager.displayInfoToUser(title: "Oops", message: NSLocalizedString("ALERT_EMPTY_EMAIL", comment: ""), currentViewController: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
        
    }

}

