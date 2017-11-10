//
//  SizeViewController.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/22/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

protocol SizeDelegate : class {
    func getCurrentSize() -> CGSize
    func didChangeSize(w: CGFloat, h: CGFloat)
    func didCancelChangingSize()
}

class SizeViewController : PopupViewController {
    
    var delegate : SizeDelegate?
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var widthField: UITextField!
    
    @IBOutlet weak var heightField: UITextField!
    
    
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
            self.delegate?.didCancelChangingSize()
        }
    }
    
    @IBAction func sizeTypeChanged(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            heightField.isEnabled = false
            heightField.text = widthField.text
        } else {
            heightField.isEnabled = true
        }
    }
    
    @IBAction func setSize(_ sender: Any) {
        guard let w = Int(widthField.text ?? ""), let h = Int(heightField.text ?? "") else { return }
        
        
        dismiss(animated: true) {
            self.delegate?.didChangeSize(w: CGFloat(w), h: CGFloat(h))
        }
    }
    @IBAction func cancel(_ sender: Any) {
        
        dismiss(animated: true) {
            self.delegate?.didCancelChangingSize()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = tapGesture
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        widthField.text = "\(delegate?.getCurrentSize().width ?? 0)"
        heightField.text = "\(delegate?.getCurrentSize().height ?? 0)"
    }
    
    @IBAction func textChanged(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            heightField.text = widthField.text
        }
    }
    @IBAction func editingChanged(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            heightField.text = widthField.text
        }
    }
}

extension SizeViewController : UITextFieldDelegate {
    
}
