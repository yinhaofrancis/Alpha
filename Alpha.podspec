#
# Be sure to run `pod lib lint Alpha.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Alpha'
  s.version          = '0.1.0'
  s.summary          = 'database'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
sqlite3 database json model
                       DESC

  s.homepage         = 'https://github.com/yinhaofrancis/Alpha'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yinhaofrancis' => 'yinhao@5eplay.com' }
  s.source           = { :git => 'https://github.com/yinhaofrancis/Alpha.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.default_subspec = 'Alpha'
  s.subspec 'Alpha' do |c|
      c.source_files = 'Alpha/*.swift'
  end
  s.subspec 'Model' do |c|
      c.source_files = 'Alpha/Model/*.swift'
  end
  s.subspec 'Mirror' do |c|
      c.source_files = 'Alpha/Mirror/*.swift'
  end
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'SQLite3'
  # s.dependency 'AFNetworking', '~> 2.3'
end
