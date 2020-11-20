//
//  DraggableCloseConfig.swift
//  DraggableUIView
//
//  Created by Teju on 20/11/20.
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
