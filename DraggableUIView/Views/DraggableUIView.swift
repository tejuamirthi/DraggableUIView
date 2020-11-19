//
//  DraggableUIView.swift
//  DraggableUIView
//
//  Created by Amirthy Tejeshwar on 14/11/20.
//  Copyright © 2020 Amirthy Tejeshwar. All rights reserved.
//

import UIKit

public struct DraggableCloseConfig {
    public init(tint: UIColor? = UIColor.black.withAlphaComponent(0.6), height: CGFloat = 80, image: UIImage? = UIImage(systemName: "xmark.circle")) {
        self.tintColor = tint
        self.height = height
        self.image = image
    }
    
    public var image: UIImage?
    public var tintColor: UIColor?
    public var height: CGFloat
    public var width: CGFloat = 150
    public var contentMode: UIView.ContentMode = .scaleAspectFit
}

public class DraggableUIView: UIView {
    
    public var mode: DraggableMode = .fourCorner
    public var enableVelocity: Bool = true
    public var enableRemove: Bool = true
    public var draggableCloseConfig = DraggableCloseConfig()
    
    
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
        
        // new bottom view
        
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard enableRemove, let superView = self.superview else {
            return
        }
        superView.viewWithTag(123)?.removeFromSuperview()
        let shadowView = UIImageView()
        shadowView.isHidden = true
        shadowView.tag = 123
        superView.addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        
        shadowView.image = draggableCloseConfig.image
        shadowView.tintColor = draggableCloseConfig.tintColor
        shadowView.contentMode = draggableCloseConfig.contentMode
        
        NSLayoutConstraint.activate([
            shadowView.heightAnchor.constraint(equalToConstant: draggableCloseConfig.height),
            shadowView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            shadowView.widthAnchor.constraint(equalToConstant: draggableCloseConfig.width),
            shadowView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -30)
        ])
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
        
        if recognizer.state == .ended || recognizer.state == .cancelled {
            if enableRemove, let shadowView = self.superview?.viewWithTag(123) {
                let shadowBounds = shadowView.bounds
                shadowView.isHidden = true
                if shadowView.center.x + shadowBounds.width/2 > self.center.x, shadowView.center.x - shadowBounds.width/2 < self.center.x, shadowView.center.y - shadowBounds.height/2 < self.center.y {
                    self.removeFromSuperview()
                    shadowView.removeFromSuperview()
                }
            }
            
            
            moveToNearestPoint(recognizer)
        }
        
        
        if recognizer.state == .began {
            DispatchQueue.main.async {
                self.superview?.viewWithTag(123)?.isHidden = false
            }
            
        }
        
    }
    
    /// Moving the view to nearest valid point after the drag
    /// - Parameter gesture: gesture object is needed to make the gesture to not go over the head
    private func moveToNearestPoint(_ gesture: UIPanGestureRecognizer){
        guard let gestureView = gesture.view else {
          return
        }
        
        let finalPoint = enableVelocity ?
            getNearestPoint(getVelocityPoint(gesture, gestureView)) : getNearestPoint(self.center)
        
        UIView.animate(
            withDuration: Double(0.2),
            delay: 0,
            options: .allowUserInteraction,
            animations: {
                gestureView.center = finalPoint
            },
            completion: { (success) in
                guard success else {
                    return
                }
                if self.enableRemove, finalPoint.y > UIScreen.main.bounds.height {
                    self.removeFromSuperview()
                }
            }
        )
        
    }
    
    /// Get velocity projected points
    /// - Parameters:
    ///   - gesture: the pan gesture
    ///   - gestureView: the view that's moving
    private func getVelocityPoint(_ gesture: UIPanGestureRecognizer, _ gestureView: UIView) -> CGPoint {
        let velocity = gesture.velocity(in: gestureView.superview)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let slideMultiplier = magnitude / 200
        let slideFactor = 0.01 * slideMultiplier
        return CGPoint(
          x: gestureView.center.x + (velocity.x * slideFactor),
          y: gestureView.center.y + (velocity.y * slideFactor)
        )
    }
    
    /// Getting the nearest point where the view can move it's center to
    /// - Parameter point: Nearest point to calculate the center from
    private func getNearestPoint(_ point: CGPoint) -> CGPoint {
        var finalX = point.x // self.center.x
        var finalY = point.y // self.center.y
        
        switch mode {
        case .anywhere:
            finalX = getValidPointX(point.x)
            finalY = getValidPointY(point.y)
        case .fourCorner:
            finalY = getCornerFinalY(point.y)
            finalX = getCornerFinalX(point.x)
        case .leftRightEdge:
            finalY = getValidPointY(point.y)
            finalX = getCornerFinalX(point.x)
        case .topLeftRightBottomClose:
            finalX = getCornerFinalX(point.x)
            
            if point.y < bounds.height/2 {
                finalY = bounds.height/2
            } else if point.y >= UIScreen.main.bounds.height - bounds.height/2{
                // animate to out of screen and remove view
                finalY = UIScreen.main.bounds.height + bounds.height/2
            } else {
                finalY = getValidPointY(point.y)
            }
            
        default:
            finalY = getValidPointY(point.y)
            if point.y > self.bounds.height/2, point.y < UIScreen.main.bounds.height - bounds.height/2 {
                finalX = getCornerFinalX(point.x)
            } else {
                finalX = getValidPointX(point.x)
            }
        }
        
        if enableRemove, point.y >= UIScreen.main.bounds.height - bounds.height/2{
            // animate to out of screen and remove view
            finalY = UIScreen.main.bounds.height + bounds.height/2
        }
        
        return CGPoint(x: finalX, y: finalY)
    }
    
    /// Getting the valid X point (within the bounds)
    /// - Parameter pointX
    private func getValidPointX(_ pointX: CGFloat) -> CGFloat {
        // TODO: add a factor to move to edges if factor * self.center.x
        var finalX = pointX
        if finalX < self.bounds.width/2 {
            finalX = self.bounds.width/2
        } else if finalX > UIScreen.main.bounds.width - self.bounds.width/2 {
            finalX = UIScreen.main.bounds.width - self.bounds.width/2
        }
        return finalX
    }
    
    /// Getting the valid Y point (within the bounds)
    /// - Parameter pointY
    private func getValidPointY(_ pointY: CGFloat) -> CGFloat {
        // TODO: add a factor to move to edges if factor * self.center.y
        var finalY = pointY
        if finalY < self.bounds.height/2 {
            finalY = self.bounds.height/2
        } else if finalY > UIScreen.main.bounds.height - self.bounds.height/2 {
            finalY = UIScreen.main.bounds.height - self.bounds.height/2
        }
        return finalY
    }
    
    /// Getting the corner X point
    /// - Parameter pointX
    private func getCornerFinalX(_ pointX: CGFloat) -> CGFloat {
        var finalX: CGFloat = UIScreen.main.bounds.width - bounds.width/2
        if pointX <= UIScreen.main.bounds.width/2 {
            finalX = bounds.width/2
        }
        return finalX
    }
    
    /// Getting the corner Y point
    /// - Parameter pointY
    private func getCornerFinalY(_ pointY: CGFloat) -> CGFloat {
        var finalY: CGFloat = UIScreen.main.bounds.height - bounds.height/2
        if pointY <= UIScreen.main.bounds.height/2 {
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
