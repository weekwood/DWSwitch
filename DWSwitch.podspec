#
# Be sure to run `pod lib lint DWSwitch.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DWSwitch"
  s.version          = "0.0.2"
  s.summary          = "An animation switch."
  s.homepage         = "https://github.com/weekwood/DWSwitch"
  s.license          = 'MIT'
  s.author           = { "di wu" => "di.wu@me.com" }
  s.source           = { :git => "https://github.com/weekwood/DWSwitch.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*.swift'
  s.resources = 'Pod/Assets/*.png'

  s.frameworks = 'UIKit', 'QuartzCore'

end
