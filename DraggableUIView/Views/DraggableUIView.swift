//
//  DraggableUIView.swift
//  DraggableUIView
//
//  Created by Amirthy Tejeshwar on 14/11/20.
//  Copyright © 2020 Amirthy Tejeshwar. All rights reserved.
//

import UIKit

public class DraggableUIView: UIView {
    
    public var mode: DraggableMode = .fourCorner
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
        self.gestureRecognizers = [panRecognizer]
        panRecognizer.delegate = self
    }
    
    /// Called when there's a pan gesture over the view
    /// - Parameter recognizer: pan gesture itself is the argument to get the parameters
    @objc func detectPan(_ recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translation(in: self.superview)
        let hWidth = self.bounds.width/2
        let hHeight = self.bounds.height/2
        var point = (self.center.x + translation.x, self.center.y + translation.y)
        if point.0 < hWidth, point.0 > UIScreen.main.bounds.width - hWidth {
            if point.0 < hWidth {
                point.0 = hWidth
            } else {
                point.0 = UIScreen.main.bounds.width - hWidth
            }
        }
        
        if point.1 < hHeight, point.1 > UIScreen.main.bounds.height - hHeight {
            if point.1 < hHeight {
                point.1 = hHeight
            } else {
                point.1 = UIScreen.main.bounds.height - hHeight
            }
        }
        self.center = CGPoint(x: point.0, y: point.1)
            recognizer.setTranslation(.zero, in: self)
        
        if recognizer.state == .ended {
            moveToNearestPoint(recognizer)
        }
        
    }
    
    /// Moving the view to nearest valid point after the drag
    /// - Parameter gesture: gesture object is needed to make the gesture to not go over the head
    func moveToNearestPoint(_ gesture: UIPanGestureRecognizer){
        let point: CGPoint = getNearestPoint()
        UIView.animate(withDuration: 0.2) {
            self.center = point
            gesture.setTranslation(.zero, in: self)
        }
    }
    
    /// Getting the nearest point where the view can move it's center to
    func getNearestPoint() -> CGPoint {
        var finalX = self.center.x
        var finalY = self.center.y
        
        switch mode {
        case .fourCorner:
            if self.center.y <= UIScreen.main.bounds.height/2 {
                finalY = bounds.height/2
            } else {
                finalY = UIScreen.main.bounds.height - bounds.height/2
            }
            
        default:
            if self.center.y <= self.bounds.height {
                finalY = bounds.height/2
            } else if self.center.y >= UIScreen.main.bounds.height - bounds.height {
                finalY = UIScreen.main.bounds.height - bounds.height/2
            }
            
//            if self.center.x <= self.bounds.width {
//                finalX = bounds.width/2
//            } else if self.center.x >= UIScreen.main.bounds.width - bounds.width {
//                finalX = UIScreen.main.bounds.width - bounds.width/2
//            } else {
//                
//            }
        }
        if self.center.x <= UIScreen.main.bounds.width/2 {
            finalX = bounds.width/2
        } else {
            finalX = UIScreen.main.bounds.width - bounds.width/2
        }
        
        return CGPoint(x: finalX, y: finalY)
    }
    
}


extension DraggableUIView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
