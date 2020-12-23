//
//  DraggableViewConfig.swift
//  DraggableUIView
//
//  Created by Teju on 20/11/20.
//  Copyright © 2020 Amirthy Tejeshwar. All rights reserved.
//


public struct DraggableViewConfig {
    public init() {
        
    }
    
    public var draggableCloseConfig: DraggableCloseConfig = DraggableCloseConfig()
    // hide close after animation - nil: No Close, true: hides after animation, false: hides before animation(as soon as the gesture ends)
    public var hideCloseAfterAnimation: Bool? = nil
    public var enableVelocity: Bool = true
    public var mode: DraggableMode = .fourCorner
}
