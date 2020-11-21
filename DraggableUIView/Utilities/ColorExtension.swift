//
//  ColorExtension.swift
//  DraggableUIView
//
//  Created by Teju on 21/11/20.
//  Copyright © 2020 Amirthy Tejeshwar. All rights reserved.
//

import UIKit

extension UIColor {
    class func rgbCalculation(redColor:CGFloat, greenColor: CGFloat, blueColor: CGFloat, alphaValue:CGFloat) -> UIColor {
        
        return UIColor(red: redColor/255, green: greenColor/255, blue: blueColor/255, alpha: alphaValue)
    }
}
