//
//  Circle.swift
//  SMARTFile
//
//  Created by Tom Rogers on 03/11/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//
import UIKit

@IBDesignable
class DeleteButton: UIButton {
    
    private struct Constants {
        static let plusLineWidth: CGFloat = 2.0
        static let plusButtonScale: CGFloat = 1.0
        static let halfPointShift: CGFloat = 0.5
    }
    
    private var halfWidth: CGFloat {
        return bounds.width / 2
    }
    
    private var halfHeight: CGFloat {
        return bounds.height / 2
    }
    
    @IBInspectable var fillColor: UIColor = UIColor.red
    @IBInspectable var isAddButton: Bool = true
    
    override func draw(_ rect: CGRect) {
        //let path = UIBezierPath(ovalIn: rect.insetBy(dx: Constants.plusLineWidth, dy: Constants.plusLineWidth))
        
        //        let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: halfWidth*2, height: halfHeight*2)), byRoundingCorners:.allCorners, cornerRadii: CGSize(width:1, height:1))
        //
        UIColor.red.setStroke()
        //        path.lineWidth = Constants.plusLineWidth
        //path.stroke(with: .normal, alpha: 0.7)
        
        //set up the width and height variables
        //for the horizontal stroke
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * Constants.plusButtonScale
        let halfPlusWidth = plusWidth / 2
        
        //create the path
        let plusPath = UIBezierPath()
        
        //set the path's line width to the height of the stroke
        plusPath.lineWidth = Constants.plusLineWidth/2
        
        //move the initial point of the path
        //to the start of the horizontal stroke
        plusPath.move(to: CGPoint(
            x: (halfWidth - (halfPlusWidth/2)),
            y: (halfHeight + (halfHeight/2)) ))
        
        //add a point to the path at the end of the stroke
        plusPath.addLine(to: CGPoint(
            x: (halfWidth + (halfPlusWidth/2)),
            y: (halfHeight - (halfHeight/2))))
        
 
        //move the initial point of the path
        //to the start of the horizontal stroke
        plusPath.move(to: CGPoint(
            x: (halfWidth - (halfPlusWidth/2)),
            y: (halfHeight - (halfHeight/2))))
        
        //add a point to the path at the end of the stroke
        plusPath.addLine(to: CGPoint(
            x: (halfWidth + (halfPlusWidth/2)) ,
            y: (halfHeight + (halfHeight/2)) ))

        
        //set the stroke color
        plusPath.stroke(with: .normal, alpha: 1.0)
    }
}
