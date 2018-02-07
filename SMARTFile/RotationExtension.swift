//
//  RotationExtension.swift
//  SMARTFile
//
//  Created by Tom Rogers on 06/02/2018.
//  Copyright © 2018 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func startRotating() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = Double.pi * 2.0
        animation.duration = 3.0
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        self.layer.add(animation, forKey: "rotationAnimation")
        
        
    }
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
}
