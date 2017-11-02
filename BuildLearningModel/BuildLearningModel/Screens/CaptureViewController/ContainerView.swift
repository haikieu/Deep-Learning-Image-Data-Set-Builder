//
//  ContainerView.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/21/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

open class ContainerView : UIView {
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    open override func awakeFromNib() {
        super.awakeFromNib()
//        _ = tapGesture
        objectView.boundaryView = boundaryView
    }
    
    @IBAction func tapOnObjectView(_ sender: Any) {
        print("tap on object view")
    }
    
    @IBOutlet weak var boundaryView: UIView!
    @IBOutlet weak var toolView: UIView!
    
    @IBOutlet weak var objectView: ObjectView!
    @IBOutlet weak var objectPositionLabel: UILabel!
    @IBOutlet weak var objectTagLabel: UILabel!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    @IBAction func discardImage(_ sender: Any) {
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        
        if objectView.frame.contains(point) {
            let localPoint = self.convert(point, to: objectView)
            return objectView.hitTest(localPoint, with: event)
        }
//        } else if toolBar.frame.contains(point) {
//            let localPoint = self.convert(point, to: toolBar)
//            return toolBar.hitTest(localPoint, with: event)
//        }
//
        return super.hitTest(point, with: event)
    }
//
//    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        return super.point(inside: point, with: event)
//    }
}
