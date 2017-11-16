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
        log("tap on object view")
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
    
    deinit {
        clearLoopTimer()
    }
    
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
        if isManualCaptureMode {
            capture()
        } else {
            if timer == nil {
                activateLoopTimer()
            } else {
                clearLoopTimer()
            }
        }
    }
    
    func capture() {
        captureEffect()
        let image = captureImage(pixelBuffer: (sceneView.session.currentFrame?.capturedImage)!)
        
        containerView.previewImage.image = image
        containerView.previewView.isHidden = false
        
        let rect = containerView.objectView.frame
        let fileName = "\(tag.files.count)_\(Int(rect.origin.x.rounded(.toNearestOrAwayFromZero)))_\(Int(rect.origin.y.rounded(.toNearestOrAwayFromZero)))_\(Int(rect.width.rounded(.toNearestOrAwayFromZero)))_\(Int(rect.height.rounded(.toNearestOrAwayFromZero)))"
        let rawFile = tag.saveFile(image, name: fileName)
        tag.files.append(rawFile)
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
            if self.randomJump {
                self.moveTargetRandomly()
            }
        }
    }
    
    var isManualCaptureMode : Bool = true
    var interval : Double = 0
    var randomJump : Bool = false
    
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
        
        var cgImage : CGImage! = nil
        if let device = MTLCreateSystemDefaultDevice() {
            //Pixel buffer metadata
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            //Render cgImage
            let ciImage = CIImage.init(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.right)
            let ciContext = CIContext.init(mtlDevice: device)
            cgImage = ciContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: height, height: width))
            
        }
        return UIImage(cgImage: cgImage)
    }
    
    var timer : Timer!
    
    @objc func doTask() {
        capture()
    }
    
    func clearLoopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func activateLoopTimer() {
        guard isManualCaptureMode == false, timer == nil else { return }
        clearLoopTimer()
        
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(doTask), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func moveTargetRandomly() {
        let targetRect = containerView.objectView.frame
        let x = arc4random_uniform(UInt32(UIScreen.main.bounds.width.rounded(.toNearestOrAwayFromZero) - targetRect.size.width.rounded(.toNearestOrAwayFromZero)))
        let y = arc4random_uniform(UInt32(UIScreen.main.bounds.height.rounded(.toNearestOrAwayFromZero) - targetRect.size.height.rounded(.toNearestOrAwayFromZero)))
        let randomRect = CGRect(x: CGFloat(x), y: CGFloat(y), width: targetRect.width, height: targetRect.height)
        containerView.objectView.frame = randomRect
    }
    
    func deactivateLoopTimer() {
        
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
//                log("Throws: \(error)")
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

