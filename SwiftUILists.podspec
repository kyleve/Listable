
Pod::Spec.new do |s|
  s.name         = 'SwiftUILists'
  s.version      = '0.1.1'
  s.summary      = 'SwiftUI Wrapper for Listable Lists and content.'
  s.homepage     = 'https://github.com/kyleve/Listable'
  s.license      = { type: 'Proprietary', text: "© 2020 Square, Inc." }
  s.author       = { 'iOS Team' => 'seller-ios@squareup.com' }
  s.source       = { git: 'Not Published', tag: "podify/#{s.version}" }

  s.ios.deployment_target = '10.0'

  s.swift_versions = ['5.0']

  s.dependency 'Listable'
  s.weak_framework = 'SwiftUI'

  s.source_files = 'SwiftUILists/Sources/**/*.{swift}'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'SwiftUILists/Tests/**/*.{swift}'
    test_spec.resources = 'SwiftUILists/Tests/Resources/**/*'

    test_spec.framework = 'XCTest'

    test_spec.requires_app_host = true
  end
end
