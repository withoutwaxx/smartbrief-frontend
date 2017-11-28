//
//  ProjectsViewController.swift
//  SMARTFile
//
//  Created by Tom Rogers on 25/10/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices
import AWSS3
import Photos
import AVFoundation
import AVKit
import AssetsPickerViewController


class VideosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var noVideosLabel: UILabel!
    var videos:[NSManagedObject] = []
    var currentProject:NSManagedObject?
    let imagePicker = UIImagePickerController()
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?


    @IBOutlet weak var uploadContainer: UIView!
    @IBOutlet weak var uploadContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var uploadingLabel: UILabel!
    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var videosTable: UITableView!
    @IBOutlet weak var deleteProject: UIView!
    @IBOutlet weak var deleteProjectLabel: UILabel!
    @IBOutlet weak var receivedLabel: UILabel!
    @IBOutlet weak var receivedCircle: Circle!
    @IBOutlet weak var readyLabel: UIButton!
    @IBOutlet weak var readyCircle: Circle!
    
    

    
    
    @IBAction func readyPressed(_ sender: Any) {
        if(videos.count < 1) {
            AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: NSLocalizedString("ALERT_VIDEOS_COUNT", comment: ""), currentViewController: self)
            
        } else {
            AlertUserManager.warnUser(action: NSLocalizedString("ALERT_PROJECT_READY_ACTION", comment: ""), message: NSLocalizedString("ALERT_PROJECT_READY", comment: ""), currentViewController: self, completionHandler:
                {(success) in
                    if(success){
                        RequestDelegate.updateProject(project: self.currentProject!, readyValue: 1, completionHandler: {
                            (success, message) in
                            if(success) {
                                self.performSegue(withIdentifier: "deletedProject", sender: self)
                                
                            } else {
                                AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: message, currentViewController: self)
                            }
                        })
                    }
            })
        }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videosTable.delegate = self
        videosTable.dataSource = self
  
        setupViews()
        
    }
    
    
    func setupViews() {
        projectTitle.text = currentProject?.value(forKeyPath: "project_name") as? String
        let deleteProjectTouch = UITapGestureRecognizer(target: self, action:  #selector (self.deleteProjectAction (_:)))
        self.deleteProject.addGestureRecognizer(deleteProjectTouch)
        deleteProjectLabel.adjustsFontSizeToFitWidth = true
        receivedLabel.adjustsFontSizeToFitWidth = true
        readyLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        projectTitle.adjustsFontSizeToFitWidth = true
        if(currentProject?.value(forKeyPath: "received_state") as? Bool)! {
            receivedCircle.fillColor = UIColor.green
            
        } else {
            receivedCircle.fillColor = UIColor.red
            
        }
        
        if(currentProject?.value(forKeyPath: "ready_state") as? Bool)! {
            readyCircle.fillColor = UIColor.green
            readyLabel.isUserInteractionEnabled = false
            readyLabel.titleLabel?.textColor = UIColor.darkGray
            readyLabel.setTitle(NSLocalizedString("UI_READY", comment: ""), for: UIControlState.normal)
            deleteProject.isHidden = true
            
            
        } else {
            readyCircle.fillColor = UIColor.red
            
        }
        
    }
    
    
    func deleteProjectAction(_ sender:UITapGestureRecognizer){
        AlertUserManager.warnUser(action: NSLocalizedString("ALERT_PROJECT_DELETE_ACTION", comment: ""), message: NSLocalizedString("ALERT_PROJECT_DELETE", comment: ""), currentViewController: self, completionHandler:
            {(success) in
                if(success){
                    RequestDelegate.deleteProject(projectId: self.currentProject?.value(forKey: "project_id" ) as! String, completionHandler: {
                        (success, message) in
                        if(success) {
                           self.performSegue(withIdentifier: "deletedProject", sender: self)
                            
                        } else {
                            AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: message, currentViewController: self)
                        }
                        
                    })
          
                }
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return videos.count
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            let video = videos[indexPath.row]
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "videoCell",
                                              for: indexPath) as! VideoCell
            
            if(((video.value(forKeyPath: "video_desc") as? String)?.characters.count)! > 0){
                cell.desc.text = video.value(forKeyPath: "video_desc") as? String
                cell.desc.textColor = UIColor.white

            } else {
                cell.desc.text = "No description"
                cell.desc.textColor = UIColor.gray
            }
            
            cell.size.text = String(describing: video.value(forKeyPath: "size") ?? "") + " Mb"
            cell.uploaded.text = "Uploaded \(StringManager.getDate(date: (video.value(forKeyPath: "date_uploaded") as? Date)))"
            cell.length.text = StringManager.getTime(seconds: video.value(forKeyPath: "length") as! Int)
            
            if(currentProject?.value(forKeyPath: "ready_state") as? Bool)! {
                cell.deleteVideo.isHidden = true
                
            }
            
            return cell
    }
    
    
    
    func loadData() -> Bool {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return false
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        
        let predicate = NSPredicate(format: "project_id == %@", currentProject?.value(forKeyPath: "project_id") as! String)
        fetchRequest.predicate = predicate
        
        let sort = NSSortDescriptor(key: "date_uploaded", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        
        do {
            videos = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if(videos.count > 0) {
            return true
        }
        
        return false

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(!loadData()) {
            videosTable.isHidden = true
            noVideosLabel.isHidden = false
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showManager"){
            let uploadVC = segue.destination as! UploadsViewController
            uploadVC.currentProject = currentProject
            
        }
    }

}