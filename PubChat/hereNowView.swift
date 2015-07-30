//
//  hereNowView.swift
//  PubChat
//
//  Created by Justin Platz on 7/15/15.
//  Copyright (c) 2015 ioJP. All rights reserved.
//

import UIKit

class hereNowView: UIButton {
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    override func drawRect(rect: CGRect) {
        var path = UIBezierPath(ovalInRect: rect)
        UIColorFromRGB(0x87D37C).setFill()
        path.fill()
    }
    
}
