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



class UploadsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, AssetsPickerViewControllerDelegate, CellDelegate, UploadDelegate, UploadProgressDelegate {
    
    
    var transferUtility:AWSS3TransferUtility?
    var requests:[NSManagedObject] = []
    var activeRequests:[NSManagedObject] = []
    var completionHandler:AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var uploadExpression:AWSS3TransferUtilityUploadExpression?
    
    
    var requestQueue:[NSManagedObject] = []
    var currentProject:NSManagedObject?
    
    @IBOutlet weak var noVideosLabel: UILabel!
    @IBOutlet weak var uploadContainer: UIView!
    @IBOutlet weak var uploadContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var uploadingLabel: UILabel!
    @IBOutlet weak var selectVideos: UIView!
    @IBOutlet weak var selectProjectsLabel: UILabel!
    @IBOutlet weak var videosSummary: UILabel!
    @IBOutlet weak var uploadsTable: UITableView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    

    
    
    @IBAction func readyPressed(_ sender: Any) {
        if(requestQueue.isEmpty) {
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
        AWSManager.awsManager.uploadDelegate = self
        AWSManager.awsManager.uploadProgressDelegate = self
        uploadsTable.delegate = self
        uploadsTable.dataSource = self
        loadData()
        if(requestQueue.isEmpty) {
            uploadsTable.isHidden = true
            noVideosLabel.isHidden = false
        }
  
        setupViews()
        
        self.uploadExpression = AWSS3TransferUtilityUploadExpression()
        
        uploadExpression?.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
            DispatchQueue.main.async(execute: {
                self.updateToProgress(progress: progress.fractionCompleted)
                print("video upload progress update: \(progress.fractionCompleted)")
                
            })
        }

    }
    
    
    func setupViews() {
        videosSummary.text = " \(requestQueue.count) videos in upload queue"
        let selectVideosTouch = UITapGestureRecognizer(target: self, action:  #selector (self.addVideosAction(_:)))
        self.selectVideos.addGestureRecognizer(selectVideosTouch)
        selectProjectsLabel.adjustsFontSizeToFitWidth = true
        videosSummary.adjustsFontSizeToFitWidth = true
        
    }
    
    
    func updateView() {
        self.loadData()
        self.uploadsTable.reloadData()
        videosSummary.text = " \(requestQueue.count) videos in upload queue"
        if(!requestQueue.isEmpty) {
            uploadsTable.isHidden = false
            noVideosLabel.isHidden = true
            
        } else {
            uploadsTable.isHidden = true
            noVideosLabel.isHidden = false
            
        }
        
    }
    
    
    
    func updateToProgress(progress: Double) {
        let value = Float(progress)
        DispatchQueue.main.async(execute: {
            self.progressBar.progress = value
        })
        
    }

    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "returnToVideos", sender: self)
    
    }
    
    
    func updateToUploads() {
        RequestDelegate.getVideos(projectId: currentProject?.value(forKey: Constants.FIELD_PROJECT_ID) as! String) { (success, message) in
            
            
        }
        updateView()
        
    }
    
    
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        
        self.completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                print("upload complete")
            })
        }
        
        let videoProcesser = VideoProcessor()
        videoProcesser.processNewVideos(assets: assets, pProjectId: currentProject?.value(forKey: "project_id") as! String ,  completionHandler: { (success, duplicate) in
            
            if(success) {
                self.updateView()
                if (duplicate) {
                    AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: NSLocalizedString("ALERT_DUPLICATE_UPLOAD", comment: ""), currentViewController: self)
                }
                
                self.startNewUpload(request: self.requestQueue[0])
                
                
            } else {
                AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: NSLocalizedString("ALERT_VIDEO_UNABLE", comment: "") , currentViewController: self.parent!)
            }
            
        })
        
    }
    
    
    
    func startNewUpload(request:NSManagedObject) {
        
        let videoProcessor = VideoProcessor()
        
        self.completionHandler = { (task, error) -> Void in
            if(error != nil) {
                DataManager.resetUploadTasks(ids: [Int(task.taskIdentifier)], completionHandler: { (success) in
                    if(success) {
                        
                        
                    }
        
                })
                
                AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS"
, comment: ""), message: NSLocalizedString("ALERT_UPLOAD_FAIL", comment: ""), currentViewController: self)
                
                
            } else {
                
                
            }
            
        }
        
        videoProcessor.createVideoFile(request: request, completionHandler: {(success, url) in
            if(success) {
 
                AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_SUCCESS", comment: ""), message: NSLocalizedString("ALERT_UPLOAD_START", comment: ""), currentViewController: self)

                if let newUrl = url {
        
                    let transfer = AWSS3TransferUtility.default()
                    
                    transfer.uploadFile(newUrl, bucket: "finalsmartfilebucket", key: request.value(forKey: Constants.FIELD_VIDEO_ID) as! String, contentType: "video/mp4", expression: self.uploadExpression, completionHandler: self.completionHandler)
                    
                    
                    
                    transfer.getUploadTasks().continueWith(block: {
                        (task) in
                        
                        if let uploadTasks = task.result as? [AWSS3TransferUtilityUploadTask] {
                            for upload in uploadTasks {
                                if(upload.key == request.value(forKey: Constants.FIELD_VIDEO_ID) as! String) {
                                    
                                    DataManager.setUploadTaskActive(request: request, localUrl: newUrl, taskId: Int(upload.taskIdentifier), completionHandler: { (success) in
                                        if(success) {
                                            
                                            
                                        }
                                        
                                    })
                                    
                                }
                                
                            }
                            
                        }
                        
                        return nil
                        
                    })
        
            } else {
                AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: NSLocalizedString("ALERT_UPLOAD_NO_START", comment: ""), currentViewController: self)
                    
                    DataManager.deleteMultiple(ids: [request.value(forKey: Constants.FIELD_VIDEO_ID) as! String], field: Constants.FIELD_VIDEO_ID, entity: Constants.ENTITY_UPLOAD_REQUEST, completionHandler: { (success) in
                        
                        
                    })
            }
        
        }
        
        })
        
    }
    
    
    
    func addVideosAction(_ sender:UITapGestureRecognizer){
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .notDetermined  {
            PHPhotoLibrary.requestAuthorization({status in
                
            })
        }
        
        let pickerConfig = AssetsPickerConfig()
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue )
        
        pickerConfig.assetFetchOptions = [
            .smartAlbum: options,
            .album: options
        ]
        
        let picker = AssetsPickerViewController(pickerConfig: pickerConfig)
        picker.pickerDelegate = self
        present(picker, animated: true, completion: nil)
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return requestQueue.count
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            let request = requestQueue[indexPath.row]
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "uploadCell",
                                              for: indexPath) as! UploadCell
            
            cell.indexPath = indexPath
            cell.delegateCell = self
            
            if(((request.value(forKeyPath: "desc") as? String)?.count)! > 0){
                cell.descLabel.text = request.value(forKeyPath: "video_desc") as? String
                cell.descLabel.textColor = UIColor.white

            } else {
                cell.descLabel.text = "No description"
                cell.descLabel.textColor = UIColor.gray
            }
            
            cell.sizeLabel.text = String(describing: request.value(forKeyPath: "size") ?? "") + " Mb"
            cell.dateLabel.text = "Added \(StringManager.dateToStringDate(date: (request.value(forKeyPath: "added") as? Date)))"
            cell.lengthLabel.text = StringManager.getTime(seconds: request.value(forKeyPath: "length") as! Int)
            
            if(request.value(forKey: "active_state") as? Bool == true) {
                cell.deleteButton.isHidden = true
                
            } else {
                cell.deleteButton.isHidden = false
                
            }
            
            return cell
    }
 
    
    func didTapCell(index: IndexPath) {
        DataManager.deleteMultiple(ids: [requestQueue[index.row].value(forKey: ("video_id")) as! String], field: Constants.FIELD_VIDEO_ID, entity: Constants.ENTITY_UPLOAD_REQUEST, completionHandler:  {
            (success) in
                self.updateView()
            
        })
        
    }
    
    
    func loadData() {
        let sort = NSSortDescriptor(key: "added", ascending: false)
        var predicates:[NSPredicate] = []
        predicates.append(NSPredicate(format: "uploaded_state = %@", false as CVarArg))
        
        requestQueue = DataManager.getUploadRequests(predicates: predicates, sort: [sort], bg: false, context: nil)

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "returnToVideos"){
            let videoVC = segue.destination as! VideosViewController
            videoVC.currentProject = currentProject
            
        }
    }
    


}



