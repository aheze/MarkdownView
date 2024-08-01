// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarkdownView",
    platforms: [
      .macOS(.v13),
      .iOS(.v16),
      .tvOS(.v16),
      .watchOS(.v9),
    ],
    products: [
        .library(name: "MarkdownView", targets: ["MarkdownView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/aheze/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/raspu/Highlightr.git", from: "2.1.2"),
        .package(url: "https://github.com/aheze/MathJaxSwift.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "MarkdownView",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(
                    name: "Highlightr",
                    package: "Highlightr",
                    condition: .when(platforms: [.iOS, .macOS])
                ),
                .product(name: "MathJaxSwift", package: "MathJaxSwift"),
            ],
            path: "Sources"
        ),
    ]
)
