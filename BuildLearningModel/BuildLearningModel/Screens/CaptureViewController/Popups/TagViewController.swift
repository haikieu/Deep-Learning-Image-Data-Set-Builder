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
    func getCurrentTag() -> Tag
    func didSetTagName(_ tagName: String)
}

class TagViewController : PopupViewController {
    
    weak var delegate : TagDelegate?
    
    @IBOutlet weak var tagField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = tapGesture
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tagField.text = delegate?.getCurrentTag().tagName
    }
    
    @IBAction func setTag(_ sender: Any) {
        
        self.showLoading("Rename to \(self.tagField.text!)") {
            
            self.rename() { (success) in
                if success {
                    self.delegate?.didSetTagName(self.tagField.text!)
                }
                self.dismissLoading(completion: nil)
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    private func rename(_ completion: ((Bool)->Void)? = nil) {
        guard let newName = tagField.text, newName.isEmpty != true else { return }
        guard let tag = self.delegate?.getCurrentTag() else { return }
        guard newName != tag.tagName else { return }
        
        tag.rename(to: newName, completion: completion)
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
