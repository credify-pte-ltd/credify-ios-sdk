Pod::Spec.new do |spec|

  spec.name         = "Credify"
  spec.version      = "0.4.1"
  spec.summary      = "serviceX SDK is for marketplaces to integrate Credify serviceX."
  spec.description  = "This is an SDK for Credify serviceX distributed for iOS platform."
  spec.homepage     = "https://github.com/credify-pte-ltd/credify-ios-sdk"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license      = "MIT"


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.author             = { "Credify Pte. Ltd." => "dev@credify.one" }
  spec.social_media_url   = "https://github.com/credify-pte-ltd"


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.ios.deployment_target = '10.0'
  spec.swift_version = '5.0'

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source       = { :git => "https://github.com/credify-pte-ltd/credify-ios-sdk.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source_files  = "Credify/Credify/**/*.{swift}"

  # spec.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  spec.resources = "Credify/Credify/**/*.{storyboard,xib,xcassets,json,png,jpg,jpeg,plist,ttf,strings}"

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.dependency "Alamofire", "~> 5.4"
  spec.dependency "lottie-ios", "3.1.9"

end
