require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name             = 'DLShareModuleIOS'
  s.version          = '0.1.0'
  s.summary          = 'A short description of DLShareModuleIOSDevelop.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/qq912276337/DLShareModuleIOSDevelop'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'qq912276337' => 'smlsjq@163.com' }
  s.source           = { :git => 'https://github.com/qq912276337/DLShareModuleIOSDevelop.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'lib/ios/DLShareModuleIOSDevelop/DLShareModuleIOSDevelop/Classes/*'
  
  # s.resource_bundles = {
  #   'DLShareModuleIOSDevelop' => ['DLShareModuleIOSDevelop/Assets/*.png']
  # }

# s.public_header_files = 'lib/ios/DLShareModuleIOSDevelop/DLShareModuleIOSDevelop/Classes/*.h'

	s.frameworks = 'UIKit'
    s.dependency 'DLShareLib'
    s.dependency 'SDWebImage'
    s.dependency 'Masonry'
end
