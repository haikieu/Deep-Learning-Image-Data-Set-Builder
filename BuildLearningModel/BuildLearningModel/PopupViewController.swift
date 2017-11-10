//
//  PopupViewController.swift
//  BuildLearningModel
//
//  Created by KIEU, HAI on 11/9/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

class PopupViewController : BaseViewController {
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.container?.layer.cornerRadius = 20
        
        // Listen for keyboard appearances and disappearances
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard UIScreen.main.bounds.height <= 568 else { return }
        
        UIView.animate(withDuration: 0.5) {
            self.container?.transform = CGAffineTransform(translationX: 0, y: -100)
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        guard UIScreen.main.bounds.height <= 568 else { return }
        
        UIView.animate(withDuration: 0.5) {
            self.container?.transform = .identity
        }
    }
}
