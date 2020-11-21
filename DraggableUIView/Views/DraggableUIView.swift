//
//  DraggableUIView.swift
//  DraggableUIView
//
//  Created by Amirthy Tejeshwar on 14/11/20.
//  Copyright © 2020 Amirthy Tejeshwar. All rights reserved.
//

import UIKit

public class DraggableUIView: UIView {
    
    public var config: DraggableViewConfig = DraggableViewConfig()
    
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
        
        guard self.config.enableRemove, let superView = self.superview else {
            return
        }
        superView.viewWithTag(123)?.removeFromSuperview()
        let shadowView = BackgroundCloseView(config: self.config.draggableCloseConfig)
        shadowView.isHidden = true
        shadowView.tag = 123
        superView.addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shadowView.heightAnchor.constraint(equalToConstant: self.config.draggableCloseConfig.height + 40),
            shadowView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            shadowView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            shadowView.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
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
        
        if (recognizer.state == .ended || recognizer.state == .cancelled), let gestureView = recognizer.view {
            afterPanEnded(recognizer, gestureView)
        }
        
        if recognizer.state == .began {
            DispatchQueue.main.async {
                self.superview?.viewWithTag(123)?.isHidden = false
            }
        }
        
    }
    
    /// Method that is called after the pan gestures ended or cancelled
    /// - Parameters:
    ///   - recognizer: gesture object is needed to make the gesture to not go over the head
    ///   - gestureView: view on which the gesture is applied
    private func afterPanEnded(_ recognizer: UIPanGestureRecognizer, _ gestureView: UIView) {
        // removing the view from superview on some conditions
        if self.config.enableRemove, let shadowView = self.superview?.viewWithTag(123) {
            let shadowBounds = shadowView.bounds
            shadowView.isHidden = true
            let velocityPoint = getVelocityPoint(recognizer, gestureView)
            if shadowView.center.x + shadowBounds.width/2 > velocityPoint.x, shadowView.center.x - shadowBounds.width/2 < velocityPoint.x, shadowView.center.y - shadowBounds.height/2 < velocityPoint.y {
                animationFunction(duration: 0.1, delay: 0.0, animation: {
                    gestureView.center.x = velocityPoint.x
                    gestureView.center.y = UIScreen.main.bounds.height + gestureView.bounds.height/2
                }, completionAnimation: {
                    self.removeFromSuperview()
                    shadowView.removeFromSuperview()
                })
                return
            }
        }
        // if it reached here, we are moving to some point on the visible screen
        moveToNearestPoint(recognizer, gestureView)
    }
    
    /// Moving the view to nearest valid point after the drag
    /// - Parameters:
    ///   - recognizer: gesture object is needed to make the gesture to not go over the head
    ///   - gestureView: view on which the gesture is applied
    private func moveToNearestPoint(_ gesture: UIPanGestureRecognizer, _ gestureView: UIView){
        
        let finalPoint = self.config.enableVelocity ?
            getNearestPoint(getVelocityPoint(gesture, gestureView)) : getNearestPoint(self.center)

        animationFunction(animation: {
            gestureView.center = finalPoint
        })
        
    }
    
    /// UIView animation function
    /// - Parameters:
    ///   - duration: duration of the
    ///   - delay: delay for the animation
    ///   - options: animation options
    ///   - animation: animtion block
    ///   - completionAnimation: animation completion block
    private func animationFunction(duration: Double = Double(0.2), delay: TimeInterval = 0.08, options: UIView.AnimationOptions = .allowUserInteraction, animation: @escaping () -> (), completionAnimation: (()->())? = nil) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: options,
            animations: {
                animation()
                // gestureView.center = finalPoint
            },
            completion: { (success) in
                guard success, let completion = completionAnimation else {
                    return
                }
                completion()
            }
        )
    }
}

// MARK: - Points extension
extension DraggableUIView {
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
        
        switch self.config.mode {
        case .anywhere:
            finalX = getValidPointX(point.x)
            finalY = getValidPointY(point.y)
        case .fourCorner:
            finalY = getCornerFinalY(point.y)
            finalX = getCornerFinalX(point.x)
        case .leftRightEdge:
            finalY = getValidPointY(point.y)
            finalX = getCornerFinalX(point.x)
        default:
            finalY = getValidPointY(point.y)
            if point.y > self.bounds.height/2, point.y < UIScreen.main.bounds.height - bounds.height/2 {
                finalX = getCornerFinalX(point.x)
            } else {
                finalX = getValidPointX(point.x)
            }
        }
        
        return CGPoint(x: finalX, y: finalY)
    }
    
}

// MARK: - Single direction values in x and y axis
extension DraggableUIView {
    
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

// MARK: - Gesture delegate
extension DraggableUIView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
