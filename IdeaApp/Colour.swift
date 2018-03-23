//
//  Colour.swift
//  IdeaApp
//
//  Created by Lih Heng Yew on 22/03/2018.
//  Copyright © 2018 Lih Heng Yew. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func oddColour() -> UIColor {
        return UIColor(displayP3Red: 236/255, green: 93/255, blue: 87/255, alpha: 1)
    }
    
    static func evenColour() -> UIColor {
        return UIColor(displayP3Red: 236/255, green: 93/255, blue: 87/255, alpha: 0.9)
    }
    
    static func colourSelection() -> UIColor {
        return UIColor(displayP3Red: 255/255, green: 172/255, blue: 194/255, alpha: 1)
    }
    
    static func roundShape(imageView: UIImageView) -> UIImageView {
        //        let imageView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
        //        imageView.backgroundColor = UIColor.redColor()
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true
        
        return imageView
    }
    
}
