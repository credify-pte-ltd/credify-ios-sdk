//
//  UIView.swift
//  
//
//  Created by Gioan Le on 09/06/2022.
//

import Foundation
import UIKit

extension UIView {
    func setGradient(
        colors: [UIColor],
        startPoint: CGPoint,
        endPoint: CGPoint,
        cornerRadius: CGFloat = 0,
        frame: CGRect? = nil
    ) {
        let gradient = CAGradientLayer()
                
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.cornerRadius = cornerRadius
        gradient.frame = frame ?? self.bounds
        
        layer.insertSublayer(gradient, at: 0)
    }
}
