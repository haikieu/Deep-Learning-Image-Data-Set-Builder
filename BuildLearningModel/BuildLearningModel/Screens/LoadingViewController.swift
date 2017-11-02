//
//  LoadingViewController.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/31/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

class LoadingViewController : UIViewController {
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    var loadingText: String? {
        didSet {
            loadingLabel?.text = loadingText
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingLabel?.text = loadingText
    }
}
