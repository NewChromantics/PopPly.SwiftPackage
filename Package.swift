// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PopPly",
    platforms: [
		//	todo: reduce these
        .iOS(.v16),		//	Regex
		.macOS(.v13),	//	Regex
        .visionOS(.v1),
		.tvOS(.v16)
    ],
    products: [
        .library(
            name: "PopPly",
            targets: [ "PopPly" ]
        )
    ],
    targets: [
        .target(
            name: "PopPly",
			path: "Source"
        )
    ]
)
