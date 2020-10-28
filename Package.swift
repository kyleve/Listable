// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Listable",
  platforms: [
    .iOS(.v11)
  ],
  products: [
    .library(
      name: "ListableUI",
      targets: ["ListableUI"])
  ],
  targets: [
    .target(
      name: "ListableUI",
      dependencies: [],
      path: "ListableUI/Sources",
      exclude: [
        "Internal/KeyboardObserver/SetupKeyboardObserverOnAppStartup.m"
      ]
      )
  ]
)

