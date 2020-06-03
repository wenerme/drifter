#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'drifter'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugins work with device.'
  s.description      = <<-DESC
Get more device info when you can't get feom device_info plugin.
                       DESC
  s.homepage         = 'https://github.com/wenerme/drifter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Wener' => 'wener@wener.me' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

