platform :ios, '7.0'

link_with ['SpritzBrowser']

pod 'SVWebViewController', :head
pod 'Spritz-SDK', '~> 2.0.0'

post_install do |installer|
  installer.project.targets.each do |target|
	target.build_configurations.each do |config|
	  s = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
	  if s==nil then s = [ '$(inherited)' ] end
	  s.push('MR_ENABLE_ACTIVE_RECORD_LOGGING=0');
	  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = s
	end
  end
end
