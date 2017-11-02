//
//  TagViewController.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/23/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

protocol TagDelegate : class {
    func getCurrentTagName() -> String?
    func didSetTagName(_ tagName: String)
}

class TagViewController : UIViewController {
    
    weak var delegate : TagDelegate?
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var tagField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        container.layer.cornerRadius = 15
        
        _ = tapGesture
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tagField.text = delegate?.getCurrentTagName() ?? ""
    }
    
    @IBAction func setTag(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.didSetTagName(self.tagField.text ?? "")
        }
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
            
        }
    }
}
