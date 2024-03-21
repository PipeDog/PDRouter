#
# Be sure to run `pod lib lint PDRouter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PDRouter'
  s.version          = '0.1.0'
  s.summary          = 'A lightweight and flexible routing framework for iOS.'

  s.description      = <<-DESC
PDRouter is a lightweight and flexible routing framework for iOS. It supports URL-based routing, custom interceptors, and automatic parameter mapping for page navigation. With PDRouter, you can easily manage and navigate between pages in your iOS application.
                       DESC

  s.homepage         = 'https://github.com/PipeDog/PDRouter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liang' => 'leiliang0128@163.com' }
  s.source           = { :git => 'https://github.com/PipeDog/PDRouter.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.source_files = 'PDRouter/Classes/**/*'
end
