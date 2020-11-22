//
//  DraggableCloseConfig.swift
//  DraggableUIView
//
//  Created by Teju on 20/11/20.
//  Copyright © 2020 Amirthy Tejeshwar. All rights reserved.
//

import UIKit

public struct DraggableCloseConfig {
    public init(tint: UIColor? = UIColor.black.withAlphaComponent(0.6),
                height: CGFloat = 80, width: CGFloat = 150,
                image: UIImage? = UIImage(systemName: "xmark.circle"),
                contentMode: UIView.ContentMode = .scaleAspectFit,
                gradientColors: [CGColor] = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.white.withAlphaComponent(0.5).cgColor],
                paddingForImage: UIEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0),
                mode: CloseDraggableMode = .imageWithGradient) {
        self.imageTintColor = tint
        self.height = height
        self.width = width
        self.image = image
        self.contentMode = contentMode
        self.gradientColors = gradientColors
        self.paddingForImage = paddingForImage
        self.mode = mode
    }
    
    public var image: UIImage?
    public var imageTintColor: UIColor?
    public var height: CGFloat
    public var width: CGFloat
    public var contentMode: UIView.ContentMode
    public var gradientColors: [CGColor]
    public var paddingForImage: UIEdgeInsets
    public var mode: CloseDraggableMode
    
}


public enum CloseDraggableMode {
    case imageWithGradient
    case imageFillWithoutGradient
    case image
}
