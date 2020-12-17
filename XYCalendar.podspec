#
# Be sure to run `pod lib lint XYCalendar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XYCalendar'
  s.version          = '0.1.0'
  s.summary          = 'Calendar for '
  s.swift_version    = "5.0"
  s.homepage         = 'https://github.com/ShadowTourist/XYCalendar'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xiaoyu.liu' => 'dizzle0722@163.com' }
  s.source           = { :git => 'https://github.com/ShadowTourist/XYCalendar.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'XYCalendar/**/*'
  s.frameworks = 'Foundation', 'UIKit'
end
