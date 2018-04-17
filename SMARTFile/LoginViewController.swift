//
//  ViewController.swift
//  SMARTFile
//
//  Created by Tom Rogers on 25/10/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginText: UILabel!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var logo: IntroView!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailText.delegate = self
        self.passwordText.delegate = self
        logo.addIntroAnimation()
        let viewHomeTouch = UITapGestureRecognizer(target: self, action:  #selector (self.openHome (_:)))
        logo.addGestureRecognizer(viewHomeTouch)
        
        emailText.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        passwordText.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])

        
        // Do any additional setup after loading the view, typically from a nib.
    
    }
    
    


    
    
    func openHome(_ sender:UITapGestureRecognizer){
        if let url = URL(string: Constants.SMARTFILE_HOME_URL) {
            UIApplication.shared.open(url, options: [:])
        }
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
                    self.loginText.text = "Logging in.."
                    loginText.layer.isHidden = false
                    RequestDelegate.signIn(email: email, password: password, completionHandler: { (success, message) in
                        if(success) {
                            self.loginText.text = "Getting projects.."
                            DataManager.deleteAllRecords()
                            DataManager.initialiseUserNotifications()
                            RequestDelegate.getProjects(completionHandler: { (success, message) in
                                if(success) {
                                    self.performSegue(withIdentifier: "showProjects", sender: self)
                                    guard let appDelegate =
                                        UIApplication.shared.delegate as? AppDelegate else {
                                            return
                                    }
                                    
                                    let managedContext =
                                        appDelegate.persistentContainer.newBackgroundContext()
                                appDelegate.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                                    managedContext.automaticallyMergesChangesFromParent = true
                                    
                                    
                                    DispatchQueue.global(qos: .utility).async {
                                        AWSManager.sharedInstance.context = managedContext
                                        AWSManager.sharedInstance.awakenUploads()
                                        
                                    }
                
                                    
                                } else {
                                    self.loginText.layer.isHidden = true
                                    AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: message, currentViewController: self)
                                }
                            })
                                
                        } else {
                            self.loginText.layer.isHidden = true
                            AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: message, currentViewController: self)
                        }
                    })
                } else {
                    
                    AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: msg, currentViewController: self)

                }
            
            } else {
                AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: NSLocalizedString("ALERT_EMPTY_PASSWORD", comment: ""), currentViewController: self)
            }
        } else {
            AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: NSLocalizedString("ALERT_EMPTY_EMAIL", comment: ""), currentViewController: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
        
    }

}

