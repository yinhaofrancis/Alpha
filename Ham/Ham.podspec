#
# Be sure to run `pod lib lint Ham.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Ham'
  s.version          = '0.2.25'
  s.summary          = 'francis private Module'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
francis private Module with objective-C
                       DESC

  s.homepage         = 'https://github.com/yinhaofrancis/Ham'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yinhaofrancis' => '1833918721@qq.com' }
  s.source           = { :git => 'https://github.com/yinhaofrancis/Ham.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.default_subspec = 'Module'
  
  s.subspec 'Module' do |c|
    c.source_files = 'Ham/Classes/Module/**/*'
    c.public_header_files = 'Ham/Classes/Module/**/*.h'
  end
  s.subspec 'Render' do |u|
    u.platform=:ios
    u.source_files = 'Ham/Classes/Render/**/*'
    u.public_header_files = 'Ham/Classes/Render/**/*.h'
    u.user_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) HMRENDERMODULE=1' }
    u.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) HMRENDERMODULE=1' }
    u.dependency 'Ham/Module'
  end
  s.subspec 'iOS' do |u|
    u.platform=:ios
    u.source_files = 'Ham/Classes/iOS/**/*'
    u.public_header_files = 'Ham/Classes/iOS/**/*.h'
    u.user_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) HMIOS=1' }
    u.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) HMIOS=1' }
    u.dependency 'Ham/Module'
  end
  s.subspec 'H5' do |u|
    u.platform=:ios
    u.source_files = 'Ham/Classes/H5/**/*'
    u.public_header_files = 'Ham/Classes/H5/**/*.h'
    u.user_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) HMH5MODULE=1' }
    u.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) HMH5MODULE=1' }
    u.dependency 'Ham/iOS'
  end
end
