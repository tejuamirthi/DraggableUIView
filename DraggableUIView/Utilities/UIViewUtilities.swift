//
//  UIViewUtilities.swift
//  DraggableUIView
//
//  Created by Teju on 21/11/20.
//  Copyright © 2020 Amirthy Tejeshwar. All rights reserved.
//

import UIKit

extension UIView {
    func add(toParent parent: UIView?, leadingPadding leading: CGFloat = 0, trailingPadding trailing: CGFloat = 0, topPadding top:CGFloat = 0, bottomPadding bottom: CGFloat = 0) {
        guard let parentView = parent else {
            return
        }
        parent?.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: leading).isActive = true
        self.trailingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: trailing).isActive = true
        self.topAnchor.constraint(equalTo: parentView.topAnchor, constant: top).isActive = true
        self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: bottom).isActive = true
    }
}
