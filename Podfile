source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'
# Yep.
inhibit_all_warnings!
use_frameworks!

target 'YoutubeExampleApp' do
  pod 'Kingfisher', '5.13.3'
  pod 'EasyPeasy', '1.8.0'
  pod 'R.swift'
  pod 'RealmSwift'
  pod 'Then'
end
#
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    # Fix IB related build errors -  see https://github.com/CocoaPods/CocoaPods/issues/5334#issuecomment-255831772
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = [
      '$(FRAMEWORK_SEARCH_PATHS)'
    ]
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end

  installer.pods_project.targets.each do |target|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
