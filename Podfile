source 'https://cdn.cocoapods.org/'

platform :ios, '11.0'

project 'Demo/Demo.xcodeproj'
workspace 'Demo/Demo.xcworkspace'

use_frameworks!

target 'Demo' do
	# Local Pods
	pod 'ListableUI', :path => 'ListableUI.podspec', :testspecs => ['Tests']
	pod 'BlueprintUILists', :path => 'BlueprintUILists.podspec', :testspecs => ['Tests']

	# External Pods
	pod 'BlueprintUI', :path => '~/Desktop/Development/Blueprint1/BlueprintUI.podspec'
	pod 'BlueprintUICommonControls', :path => '~/Desktop/Development/Blueprint1/BlueprintUICommonControls.podspec'

	# Internal Pods
	pod 'EnglishDictionary', :path => 'Internal Pods/EnglishDictionary/EnglishDictionary.podspec'
end


target 'Test Targets' do
	# XCTest-Referencing Pods
	pod 'Snapshot', :path => 'Internal Pods/Snapshot/Snapshot.podspec', :testspecs => ['Tests']
end

