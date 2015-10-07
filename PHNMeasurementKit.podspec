

Pod::Spec.new do |s|

s.name         = "PHNMeasurementKit"
s.version      = "0.3.0"
s.summary      = "SDK for performance marketing event tracking from Performance Horizon"
s.description  = "SDK for tracking installs and events within native apps, part of Performance Horizon's affiliate tracking service"
s.homepage     = "https://github.com/PerformanceHorizonGroup/measurementkit-cocoapod"

s.license      = "MIT"

s.author       = { "Performance Horizon" => "support@phgsupport.com" }

s.platform     = :ios, "7.1"

s.source_files  = "*.h"
s.preserve_path = "*.a"
s.vendored_library  = "libPHNMeasurementKit-pod.a"
s.source       = { :git => "https://github.com/PerformanceHorizonGroup/measurementkit-cocoapod.git", :tag => '0.3.0'}

s.dependency 'Reachability', '~> 3.2'
s.frameworks = 'UIKit', 'SystemConfiguration', 'Security'
end