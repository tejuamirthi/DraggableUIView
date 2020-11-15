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
    @objc private func detectPan(_ recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translation(in: self.superview)
        let hWidth = self.bounds.width/2
        let hHeight = self.bounds.height/2
        var point = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        if point.x < hWidth, point.x > UIScreen.main.bounds.width - hWidth {
            if point.x < hWidth {
                point.x = hWidth
            } else {
                point.x = UIScreen.main.bounds.width - hWidth
            }
        }
        
        if point.y < hHeight, point.y > UIScreen.main.bounds.height - hHeight {
            if point.y < hHeight {
                point.y = hHeight
            } else {
                point.y = UIScreen.main.bounds.height - hHeight
            }
        }
        self.center = CGPoint(x: point.x, y: point.y)
        recognizer.setTranslation(.zero, in: self)
        
        if recognizer.state == .ended {
            moveToNearestPoint(recognizer)
        }
        
    }
    
    /// Moving the view to nearest valid point after the drag
    /// - Parameter gesture: gesture object is needed to make the gesture to not go over the head
    private func moveToNearestPoint(_ gesture: UIPanGestureRecognizer){
        let point: CGPoint = getNearestPoint()
        UIView.animate(withDuration: 0.2) {
            self.center = point
            gesture.setTranslation(.zero, in: self)
        }
    }
    
    /// Getting the nearest point where the view can move it's center to
    private func getNearestPoint() -> CGPoint {
        var finalX = self.center.x
        var finalY = self.center.y
        
        switch mode {
        case .fourCorner:
            finalY = getCornerFinalY()
            finalX = getCornerFinalX()
        case .leftRightEdge:
            finalY = getValidPointY()
            finalX = getCornerFinalX()
        default:
            finalY = getValidPointY()
            if self.center.y > self.bounds.height/2, self.center.y < UIScreen.main.bounds.height - bounds.height/2 {
                finalX = getCornerFinalX()
            } else {
                finalX = getValidPointX()
            }
        }
        
        return CGPoint(x: finalX, y: finalY)
    }
    
    /// Getting the valid X point (within the bounds)
    private func getValidPointX() -> CGFloat {
        // TODO: add a factor to move to edges if factor * self.center.x
        var finalX = self.center.x
        if finalX < self.bounds.width/2 {
            finalX = self.bounds.width/2
        } else if finalX > UIScreen.main.bounds.width - self.bounds.width/2 {
            finalX = UIScreen.main.bounds.width - self.bounds.width/2
        }
        return finalX
    }
    
    /// Getting the valid Y point (within the bounds)
    private func getValidPointY() -> CGFloat {
        // TODO: add a factor to move to edges if factor * self.center.y
        var finalY = self.center.y
        if finalY < self.bounds.height/2 {
            finalY = self.bounds.height/2
        } else if finalY > UIScreen.main.bounds.height - self.bounds.height/2 {
            finalY = UIScreen.main.bounds.height - self.bounds.height/2
        }
        return finalY
    }
    
    /// Getting the corner X point
    private func getCornerFinalX() -> CGFloat {
        var finalX: CGFloat = UIScreen.main.bounds.width - bounds.width/2
        if self.center.x <= UIScreen.main.bounds.width/2 {
            finalX = bounds.width/2
        }
        return finalX
    }
    
    /// Getting the corner Y point
    private func getCornerFinalY() -> CGFloat {
        var finalY: CGFloat = UIScreen.main.bounds.height - bounds.height/2
        if self.center.y <= UIScreen.main.bounds.height/2 {
            finalY = bounds.height/2
        }
        return finalY
    }
}


extension DraggableUIView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
