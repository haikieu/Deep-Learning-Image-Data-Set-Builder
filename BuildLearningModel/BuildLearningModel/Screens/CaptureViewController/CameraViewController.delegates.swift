//
//  ViewController.delegates.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/23/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

extension CameraViewController : SizeDelegate {
    func getCurrentSize() -> CGSize {
        return containerView.objectView.bounds.size
    }
    
    func didCancelChangingSize() {
        //Do anything
    }
    
    func didChangeSize(w: CGFloat, h: CGFloat) {
        let center = containerView.objectView.center
//        containerView.objectView.bounds.size = CGSize(width: w, height: h)
        objectSize = CGSize(width: w, height: h)
        containerView.objectView.center = center
    }
}

extension CameraViewController : ModeDelegate {
    func didSetMode(_ isManual: Bool, interval: Double, randomJump: Bool) {
        self.isManualCaptureMode = isManual
        self.interval = interval
        self.randomJump = randomJump
    }
}

extension CameraViewController : TagDelegate {
    func getCurrentTag() -> Tag {
        return tag
    }
    
    func didSetTagName(_ tagName: String) {
        //TODO: rename tag folder
        containerView.objectTagLabel.text = tagName
    }
}

extension CameraViewController : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self.containerView)
        if containerView.toolBar.frame.contains(location) {
            return false
        }
        return true
    }
}
