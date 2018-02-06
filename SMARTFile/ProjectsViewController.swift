//
//  ProjectsViewController.swift
//  SMARTFile
//
//  Created by Tom Rogers on 25/10/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import UIKit
import CoreData

class ProjectsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewVideoDelegate {
    
    
    var projects:[NSManagedObject] = []
    var selectedProject:NSManagedObject?

    
    @IBOutlet weak var settingsWheel: UIButton!
    @IBOutlet weak var noProjectsLabel: UILabel!
    @IBOutlet weak var projectsTable: UITableView!
    @IBOutlet weak var activityWheel: UIActivityIndicatorView!
    
    
    @IBAction func newProject(_ sender: Any) {
        AlertUserManager.getInfoFromUser(title: NSLocalizedString("ALERT_NEW_PROJECT_TITLE", comment: ""), message: NSLocalizedString("ALERT_NEW_PROJECT", comment: ""), finishedAction: NSLocalizedString("UI_CREATE", comment: ""), placeholder: NSLocalizedString("UI_PROJECT_NAME", comment: ""), currentViewController: self, completionHandler:
            {(success, title) in
                if(success){
                    if(title.count > 0 && title.count < 140) {
                        
                        self.startWheel()
                        
                        RequestDelegate.newProject(projectTitle: title, completionHandler: {
                        (success, message) in
                            if(success) {
                                self.loadData()
                                if(!self.projects.isEmpty) {
                                    self.projectsTable.isHidden = false
                                    self.noProjectsLabel.isHidden = true
                                
                                }
                                
                                self.projectsTable.reloadData()
                                
                            } else {
                                AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: message, currentViewController: self)
                            }
                            
                            self.stopWheel()
                        
                        })
                    } else {
                        AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: NSLocalizedString("ALERT_PROJECT_NAME_SHORT", comment: ""), currentViewController: self)
                        
                    }
                }
            })
    }
    
    
    
    func updateToVideo() {
        RequestDelegate.getProjects { (success, message) in
            if(success) {
                self.loadData()
                self.projectsTable.reloadData()
                self.projectsTable.setNeedsLayout()
                
            }
            
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectsTable.delegate = self
        projectsTable.dataSource = self
        projectsTable.tableFooterView = UIView()
        AWSManager.sharedInstance.videoDelegate = self
        settingsWheel.startRotating(duration: 2)

        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return projects.count
    }
    
    
    func startWheel () {
        activityWheel.startAnimating()
        activityWheel.isHidden = false
        
    }
    
    
    func stopWheel () {
        activityWheel.stopAnimating()
        activityWheel.isHidden = true
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let project = projects[indexPath.row]
        startWheel()
        RequestDelegate.getVideos(projectId: (project.value(forKeyPath: "project_id") as? String)!, completionHandler: {
            (success, message) in
            self.stopWheel()
            if(success) {
                self.selectedProject = project
                self.performSegue(withIdentifier: "showVideos", sender: self)

            } else {
                AlertUserManager.displayInfoToUser(title: "Oops", message: message, currentViewController: self)
                
            }
        
        })
    
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            let project = projects[indexPath.row]
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "projectCell",
                                              for: indexPath) as! ProjectCell
            
            if(project.value(forKeyPath: "ready_state") as! Bool == true){
                cell.readyValue.fillColor = UIColor.green
            } else {
                cell.readyValue.fillColor = UIColor.red
            }
            if(project.value(forKeyPath: "received_state") as! Bool == true){
                cell.receivedValue.fillColor = UIColor.green
            } else {
                cell.receivedValue.fillColor = UIColor.red
            }
            
            cell.readyValue.setNeedsDisplay()
            cell.receivedValue.setNeedsDisplay()
            
    
            let colorView = UIView()
            colorView.backgroundColor = UIColor.black
            cell.selectedBackgroundView = colorView
            
            if(((project.value(forKeyPath: "project_name") as? String)?.count)! > 0){
                cell.projectTitle.text = project.value(forKeyPath: "project_name") as? String
                cell.projectTitle.textColor = UIColor.white
                
            } else {
                cell.projectTitle.text = "No Project Title"
                cell.projectTitle.textColor = UIColor.gray
            }
            
            cell.videoCount.text = String(describing: project.value(forKeyPath: "video_count") ?? "") + " Videos"
            cell.created.text = "Created \(StringManager.dateToStringDate(date: (project.value(forKeyPath: "date_created") as? Date)))"
            

            return cell
    }
    
    
    
    func loadData() {
        projects = DataManager.getProjects(id:nil)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        if(projects.isEmpty) {
            projectsTable.isHidden = true
            noProjectsLabel.isHidden = false
        } else {
            projectsTable.isHidden = false
            noProjectsLabel.isHidden = true
            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showVideos"){
            let videoVC = segue.destination as! VideosViewController
            videoVC.currentProject = selectedProject
            
        }
    }

    
}
