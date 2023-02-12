# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'SPFReminder' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SPFReminder
 pod 'Alamofire', '~> 5.0'
 pod 'Moya', '~> 14.0'
 pod 'ForecastIO', '~> 5.1'
 pod 'ScrollableGraphView', '~> 4.0'
 pod 'SwiftMessages', '~> 6.0'
 pod 'iCarousel', '~> 1.8'
 pod 'Firebase/Analytics'
 pod 'AlamofireImage', '~> 4.1'
 pod 'Presentr'
 pod 'Pulsator'
 pod 'TagListView', '~> 1.4'
 pod 'AMPopTip'
 pod 'FirebaseCrashlytics'
 pod 'MaterialComponents'
 pod 'SDWebImage'
 pod 'MicrosoftFluentUI'

end

  post_install do |installer|
   installer.pods_project.targets.each do |target|
       target.build_configurations.each do |config|
          if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 14.0
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
          end
       end
   end
end
