//
//  NewProjectViewController.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 11/1/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

protocol NewProjectDelegate : class {
    func didAddNewProject(projectName: String)
}

class NewProjectViewController : UIViewController {
    weak var delegate : NewProjectDelegate?
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBAction func handleAddAction(_ sender: Any) {
        
        dismiss(animated: true) {
            if let projectName = self.textField.text, projectName.isEmpty == false {
                self.delegate?.didAddNewProject(projectName: projectName)
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
