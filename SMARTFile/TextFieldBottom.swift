//
//  TextFieldBottom.swift
//  SMARTFile
//
//  Created by Tom Rogers on 06/02/2018.
//  Copyright © 2018 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation
import UIKit


extension UITextField {
    func setBottomBorder() {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor(alpha: 1.0, red: 254, green: 114, blue: 62).cgColor
        border.frame = CGRect(x: 0, y: 50 , width:  self.frame.size.width, height: 1.0)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
