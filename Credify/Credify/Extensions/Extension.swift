//
//  Extension.swift
//  
//
//  Created by Gioan Le on 17/03/2022.
//

import Foundation

struct Extension<Base> {
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}

protocol ExtensionCompatible {
    associatedtype Compatible
    static var ex: Extension<Compatible>.Type { get }
    var ex: Extension<Compatible> { get }
}

extension ExtensionCompatible {
    static var ex: Extension<Self>.Type {
        return Extension<Self>.self
    }
    
    var ex: Extension<Self> {
        return Extension(self)
    }
}

private class BundleFinder {}

extension Bundle {
    static var serviceX: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(identifier: "one.credify.credify-sdk") ?? Bundle(identifier: "org.cocoapods.Credify") ?? .main
        #endif
    }
}
