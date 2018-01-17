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


class VideosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewVideoDelegate {
    
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
                                self.refreshView()
                                
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
        AWSManager.sharedInstance.videoDelegate = self
        videosTable.delegate = self
        videosTable.dataSource = self
  
        setupViews()
        
    }
    
    
    func updateToVideo() {
        RequestDelegate.getVideos(projectId: currentProject?.value(forKey: Constants.FIELD_PROJECT_ID) as! String) { (success, message) in
            if(success) {
                self.refreshView()
                
            }
            
        }
        RequestDelegate.getProjects { (success, error) in
            
            
        }
        
    }
    
    
    func refreshView() {
        reloadProject()
        loadData()
        videosTable.reloadData()
        if(videos.isEmpty) {
            videosTable.isHidden = true
            noVideosLabel.isHidden = false
            
        } else {
            videosTable.isHidden = false
            noVideosLabel.isHidden = true
            
        }
        if(currentProject?.value(forKeyPath: "ready_state") as? Bool == true) {
            readyCircle.fillColor = UIColor.green
            readyCircle.setNeedsDisplay()
            readyLabel.isUserInteractionEnabled = false
            readyLabel.titleLabel?.textColor = UIColor.darkGray
            readyLabel.setTitle(NSLocalizedString("UI_READY", comment: ""), for: UIControlState.normal)
            deleteProject.isHidden = true
            
            
        }
    
    }
    
    
    func setupViews() {
        projectTitle.text = currentProject?.value(forKeyPath: "project_name") as? String
        let deleteProjectTouch = UITapGestureRecognizer(target: self, action:  #selector (self.deleteProjectAction (_:)))
        self.deleteProject.addGestureRecognizer(deleteProjectTouch)
        deleteProjectLabel.adjustsFontSizeToFitWidth = true
        receivedLabel.adjustsFontSizeToFitWidth = true
        readyLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        projectTitle.adjustsFontSizeToFitWidth = true
        if(currentProject?.value(forKeyPath: "received_state") as? Bool == true) {
            receivedCircle.fillColor = UIColor.green
            
        } else {
            receivedCircle.fillColor = UIColor.red
            
        }
        
        if(currentProject?.value(forKeyPath: "ready_state") as? Bool == true) {
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
                           self.performSegue(withIdentifier: "videosToProjects", sender: self)
                            
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
            
            if(((video.value(forKeyPath: "desc") as? String)?.count)! > 0){
                cell.desc.text = video.value(forKeyPath: "desc") as? String
                cell.desc.textColor = UIColor.white

            } else {
                cell.desc.text = "No description"
                cell.desc.textColor = UIColor.gray
            }
            
            cell.size.text = String(describing: video.value(forKeyPath: "size") ?? "") + " Mb"
            cell.uploaded.text = "Uploaded \(StringManager.dateToStringDate(date: (video.value(forKeyPath: "uploaded") as? Date)))"
            cell.length.text = StringManager.getTime(seconds: video.value(forKeyPath: "length") as! Int)
            
            if(currentProject?.value(forKeyPath: "ready_state") as? Bool == true) {
                cell.deleteVideo.isHidden = true
                
            }
            
            return cell
    }
    
    
    func reloadProject() {
        let predicate = NSPredicate(format: "project_id == %@", currentProject?.value(forKeyPath: "project_id") as! String)
        let sort = NSSortDescriptor(key: "uploaded", ascending: false)
        
        currentProject = DataManager.getProjects(id: currentProject?.value(forKey: Constants.FIELD_PROJECT_ID) as! String).first
        
    }
    
    
    
    func loadData() {
        
        let predicate = NSPredicate(format: "project_id == %@", currentProject?.value(forKeyPath: "project_id") as! String)
        let sort = NSSortDescriptor(key: "uploaded", ascending: false)

        videos = DataManager.getVideos(predicates: [predicate], sort: [sort])
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
        if(videos.isEmpty) {
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
