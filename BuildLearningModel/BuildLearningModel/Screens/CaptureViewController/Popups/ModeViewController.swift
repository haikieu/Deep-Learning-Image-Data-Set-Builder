//
//  ModeViewController.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/22/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

protocol ModeDelegate : class {
    func didSetMode(_ isManual: Bool)
}

class ModeViewController : UIViewController {
    @IBOutlet weak var container: UIView!
    
    weak var delegate : ModeDelegate?
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    lazy var tapGesture : UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture(_:)))
        self.view.addGestureRecognizer(gesture)
        return gesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.container.layer.cornerRadius = 20
        _ = tapGesture
        
    }
    
    @objc func handleTapGesture(_ gesture:UITapGestureRecognizer) {
        let location = gesture.location(in: self.view)
        if container.frame.contains(location) {
            gesture.cancelsTouchesInView = true
            return
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func modeChanged(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            intervalField.isEnabled = false
        } else {
            intervalField.isEnabled = true
        }
    }
    
    @IBOutlet weak var intervalField: UITextField!
    
    @IBAction func setMode(_ sender: Any) {
        
        self.dismiss(animated: true) {
            self.delegate?.didSetMode(self.segment.selectedSegmentIndex == 0)
        }
    }
}