//
//  ModalViewController.swift
//  
//
//  Created by Gioan Le on 28/06/2022.
//

import Foundation
import UIKit
import SDWebImage

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
    
    // TODO it is for temporary use. We should have an API for get this image.
    private let imageUrl = "https://assets.credify.dev/images/housecare/banner/insurance-banner1.png"
    
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
        let promotionImageView = createPromotionImage()
        view.addSubview(promotionImageView)
        
        // Close icon
        let closeImage = createCloseIcon()
        closeImage.isHidden = true
        view.addSubview(closeImage)
        
        // Footer
        let footerImage = createFooter()
        view.addSubview(footerImage)
        
        // Load main image
        loadImage(iv: promotionImageView) {
            closeImage.isHidden = false
        }
    }
    
    private func createPromotionImage() -> UIImageView {
        let promotionClick = UITapGestureRecognizer(target: self, action: #selector(promotionClick(_:)))
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
        return promotionImageView
    }
    
    private func createCloseIcon() -> UIImageView {
        let closeViewClick = UITapGestureRecognizer(target: self, action: #selector(closeClick(_:)))
        let closeView = UIImageView(frame: CGRect(x: maxWidth - 56, y: topbarHeight + 32, width: 32, height: 32))
        closeView.image = UIImage(named: "ic_modal_close", in: Bundle.serviceX, compatibleWith: nil)
        closeView.isUserInteractionEnabled = true
        closeView.addGestureRecognizer(closeViewClick)
        closeView.contentMode = UIImageView.ContentMode.scaleAspectFit
        if #available(iOS 11.0, *) {
            closeView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        }
        return closeView
    }
    
    private func createFooter() -> UIImageView {
        let footerView = UIImageView(frame: CGRect(x: (maxWidth - 112) / 2, y: maxHeight - 16, width: 112, height: 18))
        footerView.image = UIImage(named: "ic_credify_footer", in: Bundle.serviceX, compatibleWith: nil)
        footerView.contentMode = UIImageView.ContentMode.scaleAspectFit
        if #available(iOS 11.0, *) {
            footerView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        }
        return footerView
    }
    
    private func loadImage(iv: UIImageView, onFinished: @escaping () -> Void) {
        LoadingView.start()
        
        // Using SDWebImage lib. I will cache the image
        // and the same image will display immidiately on the next time
        // https://github.com/SDWebImage/SDWebImage
        iv.sd_setImage(with: URL(string: imageUrl)) { image, error, cacheType, imageURL in
            LoadingView.stop()
            onFinished()
        }
    }
    
    @objc func closeClick(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc func promotionClick(_ sender: Any) {
        closeClick(sender)
        onPromotionClick()
    }
}
