

Pod::Spec.new do |s|

s.name         = "PHGMobileTracking"
s.version      = "0.2.1"
s.summary      = "SDK for PHG's mobile tracking service."
s.description  = "SDK for tracking installs and events using PHG's mobile tracking service."
s.homepage     = "https://github.com/PerformanceHorizonGroup/mobiletracking-cocoapod"

s.license      = "MIT"

s.author       = { "Performance Horizon Group" => "support@performancehorizongroup.com" }

s.platform     = :ios, "7.1"

s.source_files  = "*.h"
s.preserve_path = "*.a"
s.vendored_library  = "libPHGMobileTracking-pod.a"
s.source       = { :git => "https://github.com/PerformanceHorizonGroup/mobiletracking-cocoapod.git", :tag => "0.2.1"}

s.dependency 'Reachability', '~> 3.2'
s.frameworks = 'UIKit', 'SystemConfiguration', 'Security'
end