//
//  ProjectsViewController.swift
//  SMARTFile
//
//  Created by Tom Rogers on 25/10/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import UIKit
import CoreData

class ProjectsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var projects:[NSManagedObject] = []
    var selectedProject:NSManagedObject?

    
    @IBOutlet weak var noProjectsLabel: UILabel!
    @IBOutlet weak var projectsTable: UITableView!
    
    
    @IBAction func newProject(_ sender: Any) {
        AlertUserManager.getInfoFromUser(title: NSLocalizedString("ALERT_NEW_PROJECT_TITLE", comment: ""), message: NSLocalizedString("ALERT_NEW_PROJECT", comment: ""), currentViewController: self, completionHandler:
            {(success, title) in
                if(success){
                    if(title.characters.count > 0 && title.characters.count < 140) {
                        RequestDelegate.newProject(projectTitle: title, completionHandler: {
                        (success, message) in
                            if(success) {
                                if(self.loadData()) {
                                    self.projectsTable.isHidden = false
                                    self.noProjectsLabel.isHidden = true
                                }
                                self.projectsTable.reloadData()
                            } else {
                                AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: message, currentViewController: self)
                            }
                        
                        })
                    } else {
                        AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: NSLocalizedString("ALERT_PROJECT_NAME_SHORT", comment: ""), currentViewController: self)
                        
                    }
                }
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectsTable.delegate = self
        projectsTable.dataSource = self

        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return projects.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let project = projects[indexPath.row]
        RequestDelegate.getVideos(projectId: (project.value(forKeyPath: "project_id") as? String)!, completionHandler: {
            (success, message) in
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
            
            if(project.value(forKeyPath: "ready_state") as! Bool){
                cell.readyValue.fillColor = UIColor.green
            } else {
                cell.readyValue.fillColor = UIColor.red
            }
            if(project.value(forKeyPath: "received_state") as! Bool){
                cell.receivedValue.fillColor = UIColor.green
            } else {
                cell.receivedValue.fillColor = UIColor.red
            }
            
            cell.readyValue.setNeedsDisplay()
            cell.receivedValue.setNeedsDisplay()
            
    
            let colorView = UIView()
            colorView.backgroundColor = UIColor.black
            cell.selectedBackgroundView = colorView
            
            if(((project.value(forKeyPath: "project_name") as? String)?.characters.count)! > 0){
                cell.projectTitle.text = project.value(forKeyPath: "project_name") as? String
                cell.projectTitle.textColor = UIColor.white
                
            } else {
                cell.projectTitle.text = "No Project Title"
                cell.projectTitle.textColor = UIColor.gray
            }
            
            cell.videoCount.text = String(describing: project.value(forKeyPath: "video_count") ?? "") + " Videos"
            cell.created.text = "Created \(StringManager.getDate(date: (project.value(forKeyPath: "date_created") as? Date)))"
            

            return cell
    }
    
    
    
    func loadData() -> Bool {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return false
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Project")
        
        let sort = NSSortDescriptor(key: "date_created", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            projects = try managedContext.fetch(fetchRequest)

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if(projects.count > 0) {
            
            return true
        }
        
        return false
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(!loadData()) {
            projectsTable.isHidden = true
            noProjectsLabel.isHidden = false
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showVideos"){
            let videoVC = segue.destination as! VideosViewController
            videoVC.currentProject = selectedProject
            
        }
    }

    
}
