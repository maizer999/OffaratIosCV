
https://stackoverflow.com/questions/16427421/how-to-remove-cocoapods-from-a-project


# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

project 'Offarat.xcodeproj'

target 'Offarat' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Offarat
  pod 'AccordionSwift', '~> 2.0.0'
  pod 'Alamofire', '~> 4.9.1'
  pod 'SwiftyJSON'
  pod 'SVProgressHUD'
  pod 'Kingfisher'
  
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare'
  pod 'GoogleSignIn'
  
end





$ sudo gem install cocoapods-deintegrate cocoapods-clean

$ pod deintegrate

$ pod clean

$ rm Podfile
# OffaratIosCV
