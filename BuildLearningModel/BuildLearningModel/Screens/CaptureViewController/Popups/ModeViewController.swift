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
    func didSetMode(_ isManual: Bool, interval: Double, randomJump: Bool)
}

class ModeViewController : PopupViewController {
    
    weak var delegate : ModeDelegate?
    
    @IBOutlet weak var heightConstraintOfContainer: NSLayoutConstraint!
    @IBOutlet weak var randomSwitch: UISwitch!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var singleAndLoopModeView: UIView!
    @IBOutlet weak var intervalLabel: UILabel!
    
    lazy var tapGesture : UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture(_:)))
        self.view.addGestureRecognizer(gesture)
        return gesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = tapGesture
        
        modeChanged(self)
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
            singleAndLoopModeView.isHidden = false
            
            intervalField.isEnabled = false
            intervalField.isHidden = true
            intervalLabel.isHidden = true
        } else if segment.selectedSegmentIndex == 1 {
            singleAndLoopModeView.isHidden = false
            
            intervalField.isEnabled = true
            intervalField.isHidden = false
            intervalLabel.isHidden = false
        } else {
            singleAndLoopModeView.isHidden = true
        }
    }
    
    private func transiteMode() {
        
    }
    
    @IBOutlet weak var intervalField: UITextField!
    
    @IBAction func setMode(_ sender: Any) {
        
        self.dismiss(animated: true) {
//            self.delegate?.didSetMode(self.segment.selectedSegmentIndex == 0)
            let isManual = self.segment.selectedSegmentIndex == 0
            let interval = Double(self.intervalField.text ?? "0") ?? 0.0
            let randomJump = self.randomSwitch.isOn

            self.delegate?.didSetMode(isManual, interval: interval, randomJump: randomJump)
        }
    }
}
