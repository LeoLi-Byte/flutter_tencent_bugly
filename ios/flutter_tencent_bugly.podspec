#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_tencent_bugly.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_tencent_bugly'
  s.version          = '0.0.1'
  s.summary          = 'A lightweight Flutter monitoring plugin for Tencent Bugly, focusing on mobile application exception capture and operational data analysis.'
  s.description      = <<-DESC
A lightweight Flutter monitoring plugin for Tencent Bugly, focusing on mobile application exception capture and operational data analysis.
                       DESC
  s.homepage         = 'https://github.com/LeoLi-Byte'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'LeoLi-Byte' => 'sdgrlwh@163.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_tencent_bugly/Sources/flutter_tencent_bugly/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Vendored Tencent Bugly SDK (static xcframework, mirrors the SPM binaryTarget in flutter_tencent_bugly/Package.swift).
  s.vendored_frameworks = 'flutter_tencent_bugly/Frameworks/Bugly.xcframework'
  s.frameworks = 'SystemConfiguration', 'Security'
  s.libraries = 'c++', 'z'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'flutter_tencent_bugly_privacy' => ['flutter_tencent_bugly/Sources/flutter_tencent_bugly/PrivacyInfo.xcprivacy']}
end
