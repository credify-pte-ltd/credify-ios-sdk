//
//  LoadingView.swift
//  Credify
//
//  Created by Gioan Le
//

import UIKit
import Lottie
import SwiftUI

class LoadingView: UIView {
    private static let view: AnimationView = {
        let v = AnimationView(name: "credify-loading", bundle: .serviceX)
        v.loopMode = .loop
        v.contentMode = .center
        v.animationSpeed = 1
        v.backgroundColor = UIColor.clear
        return v
    }()
    
    static var isShowing: Bool {
        get {
            return view.superview != nil
        }
    }
    
    /// Displays loading view. This should be called on main thread.
    static func start(container: UIView? = nil) {
        DispatchQueue.main.async {
            if let parent = container ?? UIApplication.shared.keyWindow?.topViewController()?.view ?? UIApplication.shared.keyWindow {
                parent.addSubview(view)
                
                view.frame = parent.bounds
                view.center = parent.center
                
                parent.isUserInteractionEnabled = false
                view.play()
            }
        }
    }
    
    /// Removes loading view. This should be called on main thread.
    static func stop() {
        DispatchQueue.main.async {
            if let superView = view.superview {
                superView.isUserInteractionEnabled = true
                view.removeFromSuperview()
            }
        }
    }
}

extension UIWindow {
    func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}
