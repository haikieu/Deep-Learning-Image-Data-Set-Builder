//
//  UIApplication+ext.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/20/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    var rootViewController : ViewController? {
        return UIApplication.shared.keyWindow?.rootViewController as? ViewController
    }
}
