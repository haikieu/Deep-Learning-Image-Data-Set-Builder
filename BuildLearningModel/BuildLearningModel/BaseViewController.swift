//
//  BaseViewController.swift
//  BuildLearningModel
//
//  Created by Kieu Hai on 11/1/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    var statusBarHidden : Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

}
