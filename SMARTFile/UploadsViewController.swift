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



class UploadsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, AssetsPickerViewControllerDelegate, uploadCellDelegate, UploadDelegate, UploadProgressDelegate, NewVideoDelegate {
    
    
    var requestQueueAll:[NSManagedObject] = []
    var requestQueueCurrent:[NSManagedObject] = []
    var currentProject:NSManagedObject?
    
    @IBOutlet weak var noVideosLabel: UILabel!
    @IBOutlet weak var selectVideos: UIView!
    @IBOutlet weak var selectProjectsLabel: UILabel!
    @IBOutlet weak var videosSummary: UILabel!
    @IBOutlet weak var uploadsTable: UITableView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var allUploadsSwitch: UISwitch!
    @IBOutlet weak var progressLabel: UILabel!
    
    
    
    @IBAction func viewAllToggled(_ sender: Any) {
        uploadsTable.reloadData()
        uploadsTable.setNeedsLayout()
        
        
    }
    
    
    
    func updateToVideo() {
        RequestDelegate.getVideos(projectId: currentProject?.value(forKey: Constants.FIELD_PROJECT_ID) as! String) { (success, message) in
            }
        
        RequestDelegate.getProjects {
            (success, error) in
            }
        
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AWSManager.sharedInstance.uploadDelegate = self
        AWSManager.sharedInstance.uploadProgressDelegate = self
        uploadsTable.delegate = self
        uploadsTable.dataSource = self
        uploadsTable.tableFooterView = UIView()
        loadData(completionHandler:{
            
            (complete) in
            
            if(self.requestQueueAll.isEmpty) {
                self.uploadsTable.isHidden = true
                self.noVideosLabel.isHidden = false
            }
            
            self.setupViews()
            
        })
        

    }
    
    
    func setupViews() {
        videosSummary.text = " \(requestQueueAll.count) video(s) in upload queue"
        let selectVideosTouch = UITapGestureRecognizer(target: self, action:  #selector (self.addVideosAction(_:)))
        self.selectVideos.addGestureRecognizer(selectVideosTouch)
        selectProjectsLabel.adjustsFontSizeToFitWidth = true
        videosSummary.adjustsFontSizeToFitWidth = true
        
    }
    
    
    func updateView() {
        loadData(completionHandler: {
            (complete) in
            
            self.uploadsTable.reloadData()
            self.uploadsTable.setNeedsLayout()
            if(self.requestQueueAll.count == 1) {
                self.videosSummary.text = " \(self.requestQueueAll.count) video in upload queue"
                
            } else {
                self.videosSummary.text = " \(self.requestQueueAll.count) videos in upload queue"
                
            }
            
            if(!self.requestQueueAll.isEmpty) {
                self.uploadsTable.isHidden = false
                self.noVideosLabel.isHidden = true
                
            } else {
                self.uploadsTable.isHidden = true
                self.noVideosLabel.isHidden = false
                
            }
            
        })

    }
    
    
    
    func updateToProgress(progress: Double) {
        let value = Float(progress)
        DispatchQueue.main.async(execute: {
            self.progressBar.progress = value
            self.progressLabel.text = "\(String(format:"%.1f", value * 100))%"
        })
        
    }

    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "returnToVideos", sender: self)
    
    }
    
    //Called when either an upload task completes and becomes a video or an uploadtask is cancelled
    func updateToUploads() {
        RequestDelegate.getVideos(projectId: currentProject?.value(forKey: Constants.FIELD_PROJECT_ID) as! String) { (success, message) in
            
            
        }
        updateView()
        
    }
    
    
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        
        VideoManager.sharedInstance.processNewVideos(assets: assets, pProjectId: currentProject?.value(forKey: "project_id") as! String ,  completionHandler: { (success, duplicate) in
            
            if(success) {
                self.updateView()
                if (duplicate) {
                    AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: NSLocalizedString("ALERT_DUPLICATE_UPLOAD", comment: ""), currentViewController: self)
                }
                
                DispatchQueue.global(qos: .utility).async {
                    AWSManager.sharedInstance.awakenUploads()
                    
                }
                
                self.updateView()
                
            } else {
                AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: NSLocalizedString("ALERT_VIDEO_UNABLE", comment: "") , currentViewController: self.parent!)
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
        
        if(allUploadsSwitch.isOn) {
            return requestQueueAll.count
            
        } else {
            return requestQueueCurrent.count
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            var request:NSManagedObject
            
            if(allUploadsSwitch.isOn) {
                request = requestQueueAll[indexPath.row]
                
            } else {
                request = requestQueueCurrent[indexPath.row]
                
            }
    
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "uploadCell",
                                              for: indexPath) as! UploadCell
            
            cell.indexPath = indexPath
            cell.delegateCell = self
            
            if(!(((request.value(forKeyPath: Constants.FIELD_VIDEO_DESC) as? String)?.isEmpty)!)) {
                cell.descLabel.text = request.value(forKeyPath: Constants.FIELD_VIDEO_DESC) as? String
                cell.descLabel.textColor = UIColor.white

            } else {
                cell.descLabel.text = "Tap to add a description"
                cell.descLabel.textColor = UIColor.gray
            }
            
            cell.sizeLabel.text = String(describing: request.value(forKeyPath: "size") ?? "") + " Mb"
            cell.dateLabel.text = "Added \(StringManager.dateToStringDate(date: (request.value(forKeyPath: "added") as? Date)))"
            cell.lengthLabel.text = StringManager.getTime(seconds: request.value(forKeyPath: Constants.FIELD_VIDEO_LENGTH ) as! Int)
            
            if(request.value(forKey: Constants.FIELD_UPLOAD_ACTIVE_STATE) as? Bool == true) {
                cell.deleteButton.isHidden = true
                cell.activityWheel.startAnimating()
                
            } else {
                cell.deleteButton.isHidden = false
                cell.activityWheel.stopAnimating()
                
            }
            
            return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AlertUserManager.getInfoFromUser(title: NSLocalizedString("ALERT_VIDEO_DESC_TITLE", comment: ""), message: NSLocalizedString("ALERT_VIDEO_DESC", comment: ""), finishedAction: NSLocalizedString("UI_DONE", comment: ""), placeholder: NSLocalizedString("UI_DESC", comment: ""), currentViewController: self) {
            
            (success, text) in
            if(success) {
                var request:NSManagedObject
                if(self.allUploadsSwitch.isOn) {
                    request = self.requestQueueAll[indexPath.row]
                    
                } else {
                    request = self.requestQueueCurrent[indexPath.row]
                    
                }
                
                if(text.count > 0 && text.count < 201) {

                    DataManager.updateSingleUploadTask(findField: Constants.FIELD_VIDEO_ID, findValue: request.value(forKey: Constants.FIELD_VIDEO_ID) as! String , updateField: Constants.FIELD_VIDEO_DESC, updateValueBool: false, updateValueString: text, updateTypeBool: false, bg:false, context: nil)
                    
                    self.updateView()
                
                } else {
                    AlertUserManager.displayInfoToUser(title: NSLocalizedString("ALERT_TITLE_OOPS", comment: ""), message: NSLocalizedString("ALERT_VIDEO_DESC_LENGTH", comment: ""), currentViewController: self)
                    
                }
                
                
            }
            
        }
        
    }
    
 
    
    
    func deleteRequestPressed(index: IndexPath) {
        var request:NSManagedObject
        if(self.allUploadsSwitch.isOn) {
            request = self.requestQueueAll[index.row]
            
        } else {
            request = self.requestQueueCurrent[index.row]
            
        }
        DataManager.deleteMultiple(ids: [request.value(forKey: ("video_id")) as! String], field: Constants.FIELD_VIDEO_ID, entity: Constants.ENTITY_UPLOAD_REQUEST, bg: false, context: nil)
        
        self.updateView()
        
    }
    
    
    
    func loadData( completionHandler: @escaping (_ complete:Bool) -> ()) {
        
        let sort = NSSortDescriptor(key: "added", ascending: true)
        var predicates:[NSPredicate] = []
        predicates.append(NSPredicate(format: "uploaded_state = %@", false as CVarArg))
        

        DataManager.getUploadRequestsWithCompletion(predicates: predicates, sort: [sort], context: AWSManager.sharedInstance.context) {
            
            (requests) in
                
            self.requestQueueAll = requests
            
            predicates.append(NSPredicate(format: "\(Constants.FIELD_PROJECT_ID) = %@", self.currentProject?.value(forKey: Constants.FIELD_PROJECT_ID) as! String))
            
            DataManager.getUploadRequestsWithCompletion(predicates: predicates, sort: [sort], context: AWSManager.sharedInstance.context) {
                
                (secondRequests) in
            
                    self.requestQueueCurrent = secondRequests
                
                    completionHandler(true)
            
            }
        
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "returnToVideos"){
            let videoVC = segue.destination as! VideosViewController
            videoVC.currentProject = currentProject
            
        }
    }
    


}






