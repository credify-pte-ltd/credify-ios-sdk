//
//  UIUtils.swift
//  Credify
//
//  Created by Gioan Le on 23/03/2022.
//

import Foundation
import UIKit

class UIUtils {
    static func alert(
        from: UIViewController,
        title: String,
        errorMessage: String,
        actionText: String,
        actionHandler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: actionText, style: .default, handler: actionHandler)
        alert.addAction(action)
        from.present(alert, animated: true)
    }
}
