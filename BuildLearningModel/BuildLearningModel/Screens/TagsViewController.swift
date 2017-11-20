//
//  TagsViewController.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 11/1/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

class TagsViewController : BaseViewController {
    
    weak var project : Project!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navButton = UIBarButtonItem.init(title: "New", style: .plain, target: self, action: #selector(handleNewTagAction(_:)))
        self.navigationItem.rightBarButtonItems = [navButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = project.projectName
        self.tabBarController?.tabBar.isHidden = true
        
        loadTags()
    }
    
    func loadTags() {
        showLoading("Loading tags...") {
            self.project.loadTags(andFile: true) { (success) in
                self.tableView.reloadData()
                self.dismissLoading(completion: {})
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openNewTagVC", let vc = segue.destination as? NewTagViewController {
            vc.delegate = self
        } else if segue.identifier == "openCaptureVC", let vc = segue.destination as? CameraViewController {
            let tag = project.tags[(tableView.indexPathForSelectedRow?.row)!]
            vc.tag = tag
        }
    }
    
    @objc func handleNewTagAction(_ sender: AnyObject) {
        performSegue(withIdentifier: "openNewTagVC", sender: nil)
    }
}

extension TagsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return project.tags.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "reuse_cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuse_cell")
        }
        let tag = project.tags[indexPath.row]
        cell.textLabel?.text = tag.tagName
        cell.detailTextLabel?.text = tag.files != nil ? "\(tag.files.count) images" : "Just added"
        return cell
    }
}

extension TagsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Do something
        performSegue(withIdentifier: "openCaptureVC", sender: nil)
    }
}

extension TagsViewController : NewTagDelegate {
    
    func didAddNewTag(_ tag: Tag) {
        project.tags.insert(tag, at: 0)
        tableView.reloadData()
        tag.files = []
        
    }
    
    func askForProject() -> Project {
        return project
    }
}
