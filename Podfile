# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'


workspace 'Credify'
project 'Credify.xcodeproj'
project 'ExampleApp/ExampleApp.xcodeproj'

target 'Credify' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  project 'Credify.xcodeproj'

  # Pods for Credify
  pod "Alamofire", "5.4.0"
  pod "lottie-ios", "3.1.9"

  target 'CredifyTests' do
    # Pods for testing
  end

end


target 'ExampleApp' do
  #  use_modular_headers!
  use_frameworks!
  
  project 'ExampleApp/ExampleApp.xcodeproj'
  
  pod 'Alamofire', "5.4.0"
  pod 'DropDown'
  pod "lottie-ios", "3.1.9"
end
