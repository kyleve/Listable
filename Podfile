source 'https://cdn.cocoapods.org/'

platform :ios, '10.0'

project 'Demo/Demo.xcodeproj'
workspace 'Demo/Demo.xcworkspace'

use_frameworks!

target 'Demo' do
	# Local Pods
	pod 'Listable', :path => 'Listable.podspec', :testspecs => ['Tests']
	pod 'BlueprintLists', :path => 'BlueprintLists.podspec', :testspecs => ['Tests']
	pod 'SwiftUILists', :path => 'SwiftUILists.podspec', :testspecs => ['Tests']

	# External Pods
	pod 'BlueprintUI'
	pod 'BlueprintUICommonControls'

	# Internal Pods
	pod 'EnglishDictionary', :path => 'Internal Pods/EnglishDictionary/EnglishDictionary.podspec'
end


target 'Test Targets' do
	# XCTest-Referencing Pods
	pod 'Snapshot', :path => 'Internal Pods/Snapshot/Snapshot.podspec', :testspecs => ['Tests']
end

