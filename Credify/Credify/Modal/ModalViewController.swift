//
//  ModalViewController.swift
//  
//
//  Created by Gioan Le on 28/06/2022.
//

import Foundation
import UIKit

class ModalViewController : UIViewController {
    private var maxWidth: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.layoutFrame.width
            }
            return view.frame.width
        }
    }
    
    private var maxHeight: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.layoutFrame.height
            }
            return view.frame.height
        }
    }
    
    private var imageWidth: CGFloat {
        get {
            let width = 396.0
            
            if maxWidth < width {
                return maxWidth
            }
            return width
        }
    }
    
    private var imageHeight: CGFloat {
        get {
            let heigh = 649.0
            
            if maxHeight < heigh {
                return maxHeight
            }
            return heigh
        }
    }
    
    // https://i.ibb.co/bzYH2CF/offer.png
    private let imageUrl = "https://i.ibb.co/T0sbHCC/banner-2.png"
    
    private var onPromotionClick: (() -> Void)!
    
    static func instantiate(onPromotionClick: @escaping () -> Void) -> ModalViewController {
        let vc = ModalViewController()
        vc.onPromotionClick = onPromotionClick
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        // Main image
        let promotionClick = UITapGestureRecognizer(target: self, action: #selector(self.promotionClick(_:)))
        let promotionImageView = UIImageView(
            frame: CGRect(
                x: (maxWidth - imageWidth) / 2,
                y: (maxHeight - imageHeight) / 2,
                width: imageWidth,
                height: imageHeight
            )
        )
        promotionImageView.isUserInteractionEnabled = true
        promotionImageView.addGestureRecognizer(promotionClick)
        promotionImageView.contentMode = UIImageView.ContentMode.scaleAspectFit
        view.addSubview(promotionImageView)
        
        // Close icon
        let closeViewClick = UITapGestureRecognizer(target: self, action: #selector(self.closeClick(_:)))
        let closeView = UIImageView(frame: CGRect(x: maxWidth - 56, y: topbarHeight + 32, width: 32, height: 32))
        closeView.image = UIImage(named: "ic_modal_close", in: Bundle.serviceX, compatibleWith: nil)
        closeView.isUserInteractionEnabled = true
        closeView.addGestureRecognizer(closeViewClick)
        closeView.contentMode = UIImageView.ContentMode.scaleAspectFit
        if #available(iOS 11.0, *) {
            closeView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        }
        view.addSubview(closeView)
        
        // Footer
        let footerView = UIImageView(frame: CGRect(x: (maxWidth - 112) / 2, y: maxHeight - 16, width: 112, height: 18))
        footerView.image = UIImage(named: "ic_credify_footer", in: Bundle.serviceX, compatibleWith: nil)
        footerView.contentMode = UIImageView.ContentMode.scaleAspectFit
        if #available(iOS 11.0, *) {
            footerView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        }
        view.addSubview(footerView)
        
        // Load main image
        loadImage(iv: promotionImageView)
    }
    
    private func loadImage(iv: UIImageView) {
        LoadingView.start()        
        DispatchQueue.global(qos: .userInitiated).async {
            var image: UIImage?
            let imageURL = URL(string: self.imageUrl)
            if let url = imageURL {
                let imageData = NSData(contentsOf: url)
                DispatchQueue.main.async {
                    if imageData != nil {
                        image = UIImage(data: imageData! as Data)
                        iv.image = image
                    } else {
                        image = nil
                    }

                    LoadingView.stop()
                }
            }
        }
    }
    
    @objc func closeClick(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @objc func promotionClick(_ sender: Any) {
        self.closeClick(sender)
        self.onPromotionClick()
    }
}
