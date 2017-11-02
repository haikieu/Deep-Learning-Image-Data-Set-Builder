//
//  CGRect+ext.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/22/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    //    UIKit coordinate space
    //    Origin in the top left corner
    //    Max height and width values of the screen size in points (320 x 568 on iPhone SE)
    
    //    AVFoundation coordinate space
    //    Origin in the top left
    //    Max height and width of 1
    
    //    Vision coordinate space
    //    Origin in the bottom left
    //    Max height and width of 1
    
    var UIKit2AVFoundationSpace : CGRect {
        let base = UIScreen.main.bounds
        let x = self.origin.x / base.size.width
        let y = self.origin.y / base.size.height
        let w = self.size.width / base.size.width
        let h = self.size.height / base.size.height
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    var UIKit2VisionSpace : CGRect {
        let base = UIScreen.main.bounds
        let x = self.origin.x / base.size.width
        let y = 1 - (self.origin.y / base.size.height)
        let w = self.size.width / base.size.width
        let h = self.size.height / base.size.height
        
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    var VisionToAVFoundationSpace : CGRect {
        return CGRect(x: self.origin.x, y: 1 - self.origin.y, width: self.size.width, height: self.size.height)
    }
    
    var AVFoundationToUIKitSpace : CGRect {
        let base = UIScreen.main.bounds
        let w = base.size.width
        let h = base.size.height
        return CGRect(x: self.origin.x * w, y: self.origin.y * h, width: self.size.width * w, height: self.size.height * h)
    }
    
}
