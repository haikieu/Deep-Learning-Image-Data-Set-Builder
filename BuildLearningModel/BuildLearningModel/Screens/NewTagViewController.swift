//
//  NewTagViewController.swift
//  BuildLearningModel
//
//  Created by Kieu Hai on 11/1/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import UIKit

protocol NewTagDelegate : class {
    func didAddNewTag(_ tag: Tag)
    func askForProject() -> Project
}

class NewTagViewController: PopupViewController {

    weak var delegate : NewTagDelegate?
    
    @IBOutlet weak var textField: UITextField!

    @IBAction func handleAddAction(_ sender: Any) {
        dismiss(animated: true) {
            if let tagName = self.textField.text, tagName.isEmpty == false, let projectName = self.delegate?.askForProject().projectName, projectName.isEmpty == false {
                
                let dirPath : URL = Tag.getDirPath(tagName, projectName: projectName)
                if DocumentManager.shared.checkExisting(dirPath) {
                    //Duplicate, cannot add
                    self.alert("Duplicated", message: "This tag is used, please try another one", action: { (_) in
                        self.textField.text = ""
                    })
                } else {
                    if let tag = self.delegate?.askForProject().createTag(tagName) {
                        self.delegate?.didAddNewTag(tag)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = tapGesture
    }
    
    lazy var tapGesture : UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.view.addGestureRecognizer(gesture)
        return gesture
    }()
    
    @objc func handleTapGesture(_ gesture : UITapGestureRecognizer) {
        
        let location = gesture.location(in: self.view)
        if container.frame.contains(location) {
            gesture.cancelsTouchesInView = true
            return
        }
        
        self.dismiss(animated: true) {
            self.textField.text = ""
        }
    }

}
