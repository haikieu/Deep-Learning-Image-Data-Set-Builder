//
//  UIViewController+ext.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 11/1/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
    
    public func dismissLoading(completion: (()->Void)?) {
        guard let vc = self.presentedViewController as? LoadingViewController else { return }
        vc.dismiss(animated: false, completion: completion)
    }
    
    public func showLoading(_ text: String?, completion: (()->Void)? ) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoadingViewController") as? LoadingViewController else {
            log("Cannot show loading vc")
            return
        }
        if let loadingText = text, loadingText.isEmpty == false {
            vc.loadingText = loadingText

        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: false, completion: completion)
    }
    
    public func alert(_ title: String, message: String?, doAction: UIAlertAction? = nil, cancelAction: UIAlertAction) {
        let av = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if doAction != nil {  av.addAction(doAction!) }
        av.addAction(cancelAction)
        self.present(av, animated: true, completion: nil)
    }
    
    public func alert(_ title: String, message: String?, action: ((UIAlertAction)->Void)?) {
        let action = UIAlertAction(title: "OK", style: .default, handler: action)
        self.alert(title, message: message, cancelAction: action)
    }
}
