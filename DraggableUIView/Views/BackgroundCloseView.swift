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
        imageView.tintColor = self.config.tintColor
        imageView.contentMode = self.config.contentMode
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: self.config.height),
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: self.config.width),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16)
        ])
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addGradientLayer()
    }
    
    private func addGradientLayer() {
        self.viewWithTag(9909)?.removeFromSuperview()
        
        let backgroundView = UIView()
        backgroundView.tag = 9909
        backgroundView.backgroundColor = .clear
        backgroundView.add(toParent: self)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        let topColor = UIColor.rgbCalculation(redColor: 142, greenColor: 158, blueColor: 171, alphaValue: 0.5)
        let bottomColor = UIColor.rgbCalculation(redColor: 238, greenColor: 242, blueColor: 243, alphaValue: 0.5)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        self.sendSubviewToBack(backgroundView)
    }
}
