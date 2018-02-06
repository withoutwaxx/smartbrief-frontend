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
    
    func startRotating(duration: Double = 1) {
        let kAnimationKey = "rotation"

        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float(Double.pi)
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
}
