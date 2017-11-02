//
//  ProjectsViewController.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 11/1/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

class ProjectsViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var projects = [Project]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        
        showLoading("Loading project...") {
            Workspace.shared.loadProjects(completion: { (projects) in
                self.projects.removeAll()
                self.projects += projects
                self.tableView.reloadData()
                self.dimissLoading(completion: {})
            })
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier ?? "" == "openNewProjectVC", let vc = segue.destination as? NewProjectViewController {
            vc.delegate = self
        } else if segue.identifier ?? "" == "openTagsVC", let vc = segue.destination as? TagsViewController {
            let project = projects[tableView.indexPathForSelectedRow!.row]
            vc.project = project
        }
    }
}

extension ProjectsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell_reuse")
        
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell_reuse")
        }
        
        cell.textLabel?.text = projects[indexPath.row].projectName
        
        return cell
    }
}

extension ProjectsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openTagsVC", sender: nil)
    }
}

extension ProjectsViewController : NewProjectDelegate {
    
    
    
    func didAddNewProject(projectName: String) {
        guard projectName.isEmpty == false else { return }
        let project = Project(projectName: projectName)
        projects.append(project)
        
        tableView.reloadData()
    }
}
