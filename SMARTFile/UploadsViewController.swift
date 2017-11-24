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


class UploadsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, AssetsPickerViewControllerDelegate {
    
    var videosQueue:[NSManagedObject] = []
    var currentProject:NSManagedObject?
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    
    @IBOutlet weak var noVideosLabel: UILabel!
    @IBOutlet weak var uploadContainer: UIView!
    @IBOutlet weak var uploadContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var uploadingLabel: UILabel!
    @IBOutlet weak var videosTable: UITableView!
    @IBOutlet weak var selectVideos: UIView!
    @IBOutlet weak var selectProjectsLabel: UILabel!
    @IBOutlet weak var videosSummary: UILabel!

    
    

    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
       
        self.completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                print("upload complete")
            })
        }
    
        
        let asset = assets.object(at: 0)
        
        let docPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = docPaths[0] as AnyObject
        let docDataPath = documentsDirectory.appendingPathComponent("newvideo.MOV") as String
        
        let manager = PHImageManager.default()
        manager.requestAVAsset(forVideo: asset, options: nil, resultHandler: { (avasset, audio, info) in
            if let avassetURL = avasset as? AVURLAsset {
                print("asset", avassetURL.url as URL)
                guard let video = try? Data(contentsOf: avassetURL.url as URL) else {
                    return
                }
                
                try? video.write(to: URL(fileURLWithPath: docDataPath), options: [])
                print(docDataPath)
                AWSManager.uploadVideo(url:URL(fileURLWithPath: docDataPath), completion: self.completionHandler!)
                
                
            }
        })
        
        self.dismiss(animated:true, completion: nil)
        
        print("url \(info[UIImagePickerControllerReferenceURL] ?? "")")
        print("url \(info[UIImagePickerControllerMediaURL] ?? "")")
        
        
        //let videoURL = info[UIImagePickerControllerReferenceURL] as? URL
        
        
        
        
        
     
    }
    
    
    
    @IBAction func readyPressed(_ sender: Any) {
        if(videosQueue.count < 1) {
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
        videosSummary.text = " \(videosQueue.count) videos in upload queue"
        let selectVideosTouch = UITapGestureRecognizer(target: self, action:  #selector (self.deleteProjectAction (_:)))
        self.selectVideos.addGestureRecognizer(selectVideosTouch)
        selectProjectsLabel.adjustsFontSizeToFitWidth = true
        videosSummary.adjustsFontSizeToFitWidth = true
        
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
        
        return videosQueue.count
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            let video = videosQueue[indexPath.row]
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "videoCell",
                                              for: indexPath) as! VideoCell
            
            if(((video.value(forKeyPath: "video_desc") as? String)?.count)! > 0){
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
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoUpload")
        
        let sort = NSSortDescriptor(key: "uploaded", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        
        do {
            videosQueue = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if(videosQueue.count > 0) {
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

}
