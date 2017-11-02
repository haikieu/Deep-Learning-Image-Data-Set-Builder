//
//  ViewController.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/20/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import QuartzCore
import ARKit
import Vision
import CoreML
import MetalKit
import Metal



class CameraViewController: UIViewController {

    weak var tag : Tag!
    
    @IBAction func tapOnObjectView(_ sender: Any) {
        print("tap on object view")
    }
    @IBOutlet var containerView: ContainerView!
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var autoBtn: UIBarButtonItem!
    @IBOutlet weak var trackBtn: UIBarButtonItem!
    @IBOutlet weak var sizeBtn: UIBarButtonItem!
    let cameraLayer = AVCaptureVideoPreviewLayer.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
        startSession()
        
        _ = tapGesture
    }
    
    
    @IBAction func handleBackAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showStatusBar(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showStatusBar()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    func showStatusBar(_ show: Bool = true) {
        if let tabVC = self.presentingViewController as? TabBarController, let navVC = tabVC.viewControllers?.first as? NavigationViewController, let vc = navVC.topViewController as? BaseViewController {
            
            vc.statusBarHidden = !show
            UIView.animate(withDuration: 0.5) {
                self.setNeedsStatusBarAppearanceUpdate()
                vc.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateobjectPositionLabel()
        cameraLayer.frame = self.view.bounds
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "openSizeVC" {
            if let vc = segue.destination as? SizeViewController {
                vc.delegate = self
            }
        } else if segue.identifier ?? "" == "openModeVC" {
            if let vc = segue.destination as? ModeViewController {
                vc.delegate = self
            }
        } else if segue.identifier ?? "" == "openTagVC" {
            if let vc = segue.destination as? TagViewController {
                vc.delegate = self
            }
        }
    }
    
    var enableTracking : Bool = false
    var tracking : Bool = false
    private let visionSequenceHandler = VNSequenceRequestHandler()
    private var lastObservation: VNDetectedObjectObservation?
    
    @IBAction func handleTrackAction(_ sender: Any) {
        enableTracking = !enableTracking
        
        if enableTracking {
            
            // get the center of the tap
            // ..
            
            // convert the rect for the initial observation
            let originalRect = containerView.objectView.frame
            var convertedRect = originalRect.UIKit2VisionSpace
            
            // set the observation
            let newObservation = VNDetectedObjectObservation(boundingBox: convertedRect)
            self.lastObservation = newObservation
            
        } else {
            lastObservation = nil
            tracking = false
        }
    }
    
    @IBAction func handleCameraAction(_ sender: Any) {
        captureEffect()
        let image = captureImage(pixelBuffer: (sceneView.session.currentFrame?.capturedImage)!)
        
        containerView.previewImage.image = image
        containerView.previewView.isHidden = false
    }
    
    
    
    @IBAction func handleMoreAction(_ sender: Any) {
        
    }
    
    private func captureEffect(_ duration : TimeInterval = 0.2) {
        let effectView = UIView(frame: UIScreen.main.bounds)
        effectView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        effectView.isUserInteractionEnabled = false
        self.view.addSubview(effectView)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            effectView.alpha = 0
        }) { (finished) in
            effectView.removeFromSuperview()
        }
    }
    
    var isManualCaptureMode : Bool = true
    
    lazy var tapGesture : UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
        return gesture
    }()
    
    @objc private func handleTapGesture(_ gesture : UITapGestureRecognizer) {
//        containerView.toolBar.isHidden = !containerView.toolBar.isHidden
        handleCameraAction(gesture)
    }
    
    func captureImage(pixelBuffer: CVPixelBuffer) -> UIImage {
        
        //Pixel buffer metadata
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        let ciImage = CIImage.init(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.right)
        return UIImage(ciImage: ciImage)
//        let base = UIScreen.main.bounds
//        var x = containerView.objectView.frame.origin.y
//        var y = containerView.objectView.frame.origin.x
//        let w = containerView.objectView.frame.size.height
//        let h = containerView.objectView.frame.size.width
//
//        let cropFrame = CGRect(x: x, y: y, width: w, height: h)
//
//        return UIImage.init(ciImage: ciImage.cropped(to: cropFrame))
    }
    
    
}




extension CameraViewController : ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
    }
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//
//
//        if enableTracking && tracking == false {
//            guard let pixelBuffer = session.currentFrame?.capturedImage, let lastObservation = self.lastObservation else { return }
//
//            // create the request
//            let request = VNTrackObjectRequest(detectedObjectObservation: lastObservation, completionHandler: { (request, error) in
//                // Dispatch to the main queue because we are touching non-atomic, non-thread safe properties of the view controller
//                DispatchQueue.main.async {
//                    // make sure we have an actual result
//                    guard let newObservation = request.results?.first as? VNDetectedObjectObservation else { return }
//
//                    // prepare for next loop
//                    self.lastObservation = newObservation
//
//                    // check the confidence level before updating the UI
//                    if newObservation.confidence >= 0.3 {
//                        // hide the rectangle when we lose accuracy so the user knows something is wrong
//                        self.containerView.objectView.layer.borderColor = UIColor.red.cgColor
//                        self.containerView.objectView.layer.borderWidth = 1
//                    } else {
//                        self.containerView.objectView.layer.borderColor = UIColor.clear.cgColor
//                        self.containerView.objectView.layer.borderWidth = 0
//                        // calculate view rect
//                        var transformedRect = newObservation.boundingBox.VisionToAVFoundationSpace
////                        let convertedRect = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: transformedRect)
//                        let convertedRect = transformedRect.AVFoundationToUIKitSpace
//                        // move the highlight view
//                        self.containerView.objectView?.frame = convertedRect
//                    }
//                }
//                self.tracking = false
//            })
//
//            // set the accuracy to high
//            // this is slower, but it works a lot better
//            request.trackingLevel = .accurate
//
//            // perform the request
//            do {
//                tracking = true
//                try self.visionSequenceHandler.perform([request], on: pixelBuffer)
//            } catch {
//                print("Throws: \(error)")
//
//                self.containerView.objectView.layer.borderColor = UIColor.red.cgColor
//                tracking = false
//            }
//        }
//
//
//    }
}

extension CameraViewController : ARSCNViewDelegate {
    
}

