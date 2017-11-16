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
    func didSetMode(_ isManual: Bool, interval: Double, randomJump: Bool, capture: Bool)
}

class ModeViewController : PopupViewController {
    
    weak var delegate : ModeDelegate?
    
    @IBOutlet weak var captureSwitch: UISwitch!
    @IBOutlet weak var randomSwitch: UISwitch!
    @IBOutlet weak var segment: UISegmentedControl!
    
    lazy var tapGesture : UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture(_:)))
        self.view.addGestureRecognizer(gesture)
        return gesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            randomSwitch.isEnabled = false
            captureSwitch.isEnabled = false
            
            captureSwitch.isHidden = true
            randomSwitch.isHidden = true
            intervalField.isHidden = true
        } else {
            intervalField.isEnabled = true
            randomSwitch.isEnabled = true
            captureSwitch.isEnabled = true
            
            captureSwitch.isHidden = false
            randomSwitch.isHidden = false
            intervalField.isHidden = false
        }
    }
    
    @IBOutlet weak var intervalField: UITextField!
    
    @IBAction func setMode(_ sender: Any) {
        
        self.dismiss(animated: true) {
//            self.delegate?.didSetMode(self.segment.selectedSegmentIndex == 0)
            let isManual = self.segment.selectedSegmentIndex == 0
            let interval = Double(self.intervalField.text ?? "0") ?? 0.0
            let randomJump = self.randomSwitch.isOn
            let capture = self.captureSwitch.isOn
            self.delegate?.didSetMode(isManual, interval: interval, randomJump: randomJump, capture: capture)
        }
    }
}
