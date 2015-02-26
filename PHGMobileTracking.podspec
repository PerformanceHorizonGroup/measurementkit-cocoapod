

Pod::Spec.new do |s|

  s.name         = "PHGMobileTracking"
  s.version      = "0.0.1"
  s.summary      = "SDK for PHG's mobile tracking service."
  s.description  = "SDK for tracking installs and events using PHG's mobile tracking service."
  s.homepage     = "https://github.com/PerformanceHorizonGroup/mobiletracking-cocoapod"

  s.license      = "MIT"

  s.author             = { "Performance Horizon Group" => "support@peroformancehorizongroup.com" }

  s.platform     = :ios, "7.1"

  s.source       = { :git => "https://github.com/PerformanceHorizonGroup/mobiletracking-cocoapod.git", :tag => "0.0.1" }
  s.source_files  = "*.h"
  s.preserve_path = "*.a"
  s.libraries = "PHGMobileTracking-pod"

  s.dependency 'Reachability', '~> 3.2'
  s.frameworks = 'UIKit', 'SystemConfiguration'

  s.xcconfig = { "LIBRARY_SEARCH_PATHS" => "\"$(PODS_ROOT)/PHGMobileTracking\"" }
  #s.xcconfig = { "LIBRARY_SEARCH_PATHS" => "~/Development/PerformanceHorizon/mobile-iOS/shared/mobiletracking-cocoapod" }

end
