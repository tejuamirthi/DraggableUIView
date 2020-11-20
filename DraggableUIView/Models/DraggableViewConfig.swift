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
    public var enableRemove: Bool = false
    public var enableVelocity: Bool = true
    public var mode: DraggableMode = .fourCorner
}
