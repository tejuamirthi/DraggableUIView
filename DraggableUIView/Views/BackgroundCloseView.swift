//
//  BackgroundCloseView.swift
//  DraggableUIView
//
//  Created by Teju on 21/11/20.
//  Copyright © 2020 Amirthy Tejeshwar. All rights reserved.
//

import UIKit

class BackgroundCloseView: UIView {
    
    var config: DraggableCloseConfig = DraggableCloseConfig()
    
    init(config: DraggableCloseConfig) {
        super.init(frame: .zero)
        self.config = config
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        let imageView = UIImageView()
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        imageView.image = self.config.image
        imageView.tintColor = self.config.imageTintColor
        imageView.contentMode = self.config.contentMode
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: self.config.height),
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: self.config.width)
        ])
        
        self.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -config.paddingForImage.top).isActive = true
        self.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: config.paddingForImage.bottom + 20).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addGradientLayer()
    }
    
    private func addGradientLayer() {
        self.viewWithTag(9909)?.removeFromSuperview()
        guard config.mode == .imageWithGradient else {
            return
        }
        let backgroundView = UIView()
        backgroundView.tag = 9909
        backgroundView.backgroundColor = .clear
        backgroundView.add(toParent: self)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = config.gradientColors
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        self.sendSubviewToBack(backgroundView)
    }
}
