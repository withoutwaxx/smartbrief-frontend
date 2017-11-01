//
//  ProjectsViewController.swift
//  SMARTFile
//
//  Created by Tom Rogers on 25/10/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import UIKit
import CoreData

class ProjectsViewController: UIViewController, UITableViewDataSource {
    
    var projects:[NSManagedObject] = []

    @IBOutlet weak var projectsTable: UITableView!
    
    @IBAction func newProject(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return projects.count
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            let project = projects[indexPath.row]
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "cell",
                                              for: indexPath)
            cell.textLabel?.text = project.value(forKeyPath: "project_name") as? String
            return cell
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Project")
        
        do {
            projects = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    
}
