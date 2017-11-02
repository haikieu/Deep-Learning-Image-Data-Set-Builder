//
//  ObjectView.swift
//  BuildLearningModel
//
//  Created by Hai Kieu on 10/21/17.
//  Copyright © 2017 Hai Kieu. All rights reserved.
//

import Foundation
import UIKit

class ObjectView : UIView {
    
    weak var boundaryView : UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _ = self.tapGesture
        _ = self.panGesture
        _ = self.pinchGesture
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let positionLabel = self.positionLabel, let tagLabel = self.tagLabel else { return }
        positionLabel.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[view(300)]", options: [], metrics: [:], views: ["view":positionLabel])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[view(20)]-(-50)-|", options: [], metrics: [:], views: ["view":positionLabel])
        constraints += [NSLayoutConstraint.init(item: positionLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)]
        NSLayoutConstraint.activate(constraints)
        
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints.removeAll()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[view(300)]", options: [], metrics: [:], views: ["view":tagLabel])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[view(20)]-(-30)-|", options: [], metrics: [:], views: ["view":tagLabel])
        constraints += [NSLayoutConstraint.init(item: tagLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)]
        NSLayoutConstraint.activate(constraints)
    }
    
    var sizing : Bool = false
    var tapping : Bool = false
    lazy var tapGesture : UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture(_:)))
        self.addGestureRecognizer(gesture)
        return gesture
    }()
    
    lazy var panGesture : UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(_:)))
        self.addGestureRecognizer(gesture)
        return gesture
    }()
    
    lazy var pinchGesture : UIPinchGestureRecognizer = {
        let gesture = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinchGesture(_:)))
        self.addGestureRecognizer(gesture)
        return gesture
    }()
    
    private var currentScale = 1
    private var currentCenter : CGPoint!
    private var currentWidth : CGFloat!
    private var currentHeight : CGFloat!
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        
        let scale = gesture.scale
        switch gesture.state {
            
        case .began:
            currentCenter = self.center
            currentScale = 1
            currentWidth = self.bounds.size.width
            currentHeight = self.bounds.size.height
            return
        case .changed:
            print("pinch >>> scale \(scale)")
            self.bounds = CGRect(x: 0, y: 0, width: currentWidth * scale, height: currentHeight * scale)
            self.center = currentCenter
            return
        case .ended:
            return
        case .failed, .cancelled:
            fallthrough
        default:
            self.bounds = CGRect(x: 0, y: 0, width: currentWidth, height: currentHeight)
            self.center = currentCenter
            currentScale = 1
            currentWidth = self.bounds.size.width
            currentHeight = self.bounds.size.height
            return;
        }
    }
    
    var beginPoint : CGPoint = .zero
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        print("pan gesture = \(gesture.state.rawValue)")
        guard let parent = self.superview else { return }
        
        let newPoint = gesture.translation(in: parent)
        let location = gesture.location(in: parent)
//        let velocity = gesture.velocity(in: parent)
        
//        if checkSizing(at: location) || sizing {
        if false {
            if sizing == false {
                sizing = true
                sizingPoint = getSizingPoint(at: location)
            }
            size(at: sizingPoint, to: newPoint, with: gesture.state, gesture: gesture)
        } else {
            move(to: newPoint, with: gesture.state, gesture: gesture)
        }
        
    }
    private func checkSizing(at location: CGPoint) -> Bool {
        let p = getSizingPoint(at: location)
        return p.x != -1 || p.y != -1
    }
    private func getSizingPoint(at location: CGPoint) -> CGPoint {
        let gap = 20 as CGFloat
        var x = -1 as CGFloat
        var y = -1 as CGFloat
        if location.x > (frame.minX - gap) && location.x < (frame.minX + gap) {
            x = frame.minX //left
        }
        if location.x > (frame.maxX - gap) && location.x < (frame.maxX + gap) {
            x = frame.maxX    //right
        }
        if location.y > (frame.minY - gap) && location.y < (frame.minY + gap) {
            y = frame.minY //top
        }
        if location.y > (frame.maxY - gap) && location.y < (frame.maxY + gap) {
            y = frame.maxY    //right
        }
        return CGPoint(x: x, y: y)
    }
    
    private var sizingAtOrigin = false
    private var sizingPoint : CGPoint = .zero
    private var originalSize : CGRect = .zero
    private var originalCenter : CGPoint = .zero
    private func size(at sizePoint: CGPoint, to location: CGPoint,with state: UIGestureRecognizerState,gesture: UIPanGestureRecognizer) {
        switch state {
        case .began:
            originalSize = self.frame
            originalCenter = self.center
            break
        case .changed:
            print("sizePoint \(sizePoint)  location \(location)")
            self.bounds = CGRect(x: 0, y: 0, width: originalSize.width + location.x, height: originalSize.height + location.y)
            self.center = originalCenter
            break
        case .ended:
            
            fallthrough
        default:
            sizing = false
            sizingAtOrigin = false
            originalSize = .zero
            originalCenter = .zero
            
            break
        }
    }
    
    private func move(to newPoint: CGPoint,with state: UIGestureRecognizerState,gesture: UIPanGestureRecognizer) {
        switch state {
        case .began:
            beginPoint = newPoint
            break
        case .changed:
            self.center = CGPoint(x: self.center.x + newPoint.x, y: self.center.y + newPoint.y)
            gesture.setTranslation(.zero, in: self)
            break
        case .ended:
            if let f = boundaryView?.frame.intersection(frame), f.size.equalTo(self.frame.size) == false {
                moveInBoundary()
            }
            
            fallthrough
        default:
            beginPoint = .zero
            break
        }
    }
    
    private func moveInBoundary() {
        guard let b = boundaryView else { return }
        var x = frame.minX
        var y = frame.minY
        if frame.minX < b.frame.minX {
            x = b.frame.minX
        } else if frame.maxX > b.frame.maxX {
            x = b.frame.maxX - (frame.width)
        }
        
        if frame.minY < b.frame.minY {
            y = b.frame.minY
        } else if frame.maxY > b.frame.maxY {
            y = b.frame.maxY - (frame.height)
        }
        
        UIView.animate(withDuration: 0.5) {
            self.frame.origin = CGPoint(x: x, y: y)
        }
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        print("tap gesture = \(gesture.state)")
        tapping = !tapping
        
        if tapping {
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.green.cgColor
            
            self.backgroundColor = .clear
        } else {
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.clear.cgColor
            
            self.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        }
        
    }
    
    override var frame: CGRect { didSet { updatePositionLabel() } }
    override var center: CGPoint { didSet { updatePositionLabel() } }
    override var bounds: CGRect { didSet { updatePositionLabel() } }
    
    func updateTagName(_ name : String) {
        tagLabel?.text = name
    }
    
    private func updatePositionLabel() {
        //Update target label
        let x = round(self.frame.origin.x)
        let y = round(self.frame.origin.y)
        let w = round(self.frame.size.width)
        let h = round(self.frame.size.height)
        positionLabel?.text = "(x=\(x),y=\(y),w=\(w),h=\(h))"
    }
    
    var tagLabel : UILabel? {
        for view in self.subviews {
            if view.tag == 0 {
                return view as? UILabel
            }
        }
        return nil
    }
    
    var positionLabel : UILabel? {
        for view in self.subviews {
            if view.tag == 1 {
                return view as? UILabel
            }
        }
        return nil
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, with: event)
        return v
    }
}
