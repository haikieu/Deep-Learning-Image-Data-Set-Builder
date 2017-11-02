//
//  ViewController.others.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/20/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import ARKit

extension ViewController {
    func startSession() { sceneView?.session.run(ARWorldTrackingConfiguration(), options: .resetTracking); sceneView?.delegate = self; sceneView.session.delegate = self }
    func pauseSession() { sceneView?.session.pause() }
    
    func setupUI() {
        
        cameraLayer.frame = self.view.bounds
        
        containerView.boundaryView.layer.borderColor = UIColor.orange.cgColor
        containerView.boundaryView.layer.borderWidth = 1
        
        containerView.objectTagLabel.text = tag.tagName
        containerView.objectPositionLabel.text = ""
//        containerView.objectPositionLabel.layer.cornerRadius = 3
//        containerView.objectPositionLabel.clipsToBounds = true
//        containerView.objectPositionLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        
        progressLabel.layer.cornerRadius = progressLabel.frame.size.width / 2
        progressLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        progressLabel.layer.borderWidth = 1
        progressLabel.layer.borderColor = UIColor.white.cgColor
        progressLabel.clipsToBounds = true
        progressLabel.text = ""
        progressLabel.isHidden = true
        
        progressView.progress = 0
        progressView.isHidden = true
        
        previewView.isHidden = true
    }
    
    func updateobjectPositionLabel() {
        //Update target label
        let x = containerView.objectView.frame.origin.x
        let y = containerView.objectView.frame.origin.y
        let w = containerView.objectView.frame.size.width
        let h = containerView.objectView.frame.size.height
        containerView.objectPositionLabel.text = "(x=\(x),y=\(y),w=\(w),h=\(h))"
    }
    
}
