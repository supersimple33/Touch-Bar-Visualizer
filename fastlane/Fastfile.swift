// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    
    func beforeAll() {
        xcversion(version: "12.3")
        setupCircleCi()
    }
    
	func checkLane() {
        desc("Run code checks")
		// add actions here: https://docs.fastlane.tools/actions
        swiftlint(path:"TouchBarVisualizer") //,  ignoreExitStatus: true, raiseIfSwiftlintError: false
        swiftlint(path:"TouchBarVisualizerTests")
        
        scan(workspace: "TouchBarVisualizer.xcworkspace", scheme: "TouchBarVisualizer", derivedDataPath: "build", skipBuild: true, buildForTesting: true, xcargs:" CODE_SIGN_IDENTITY=\"\" CODE_SIGNING_REQUIRED=NO")
        scan(onlyTesting: "TouchBarVisualizerTests/VolumeTests/testAnalyze", xctestrun: "build/Build/Products/TouchBarVisualizer_macosx11.1-x86_64.xctestrun", derivedDataPath: "build", skipBuild: true, testWithoutBuilding: true)
//        if #available(OSX 11.1, *) {
//            scan(onlyTesting: "TouchBarVisualizerTests/VolumeTests/testAnalyze", xctestrun: "build/Build/Products/TouchBarVisualizer_macosx11.1-x86_64.xctestrun", derivedDataPath: "build", skipBuild: true, testWithoutBuilding: true)
//        } else {
//            scan(onlyTesting: "TouchBarVisualizerTests/VolumeTests/testAnalyze", xctestrun: "build/Build/Products/TouchBarVisualizer_macosx10.15-x86_64.xctestrun", derivedDataPath: "build", skipBuild: true, testWithoutBuilding: true)
//        }
	}
}
//xcodebuild build-for-testing -scheme "TouchBarVisualizer" -workspace "TouchBarVisualizer.xcworkspace" -derivedDataPath "build" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
//xcodebuild test-without-building -xctestrun "build/Build/Products/TouchBarVisualizer_macosx11.1-x86_64.xctestrun" -destination "platform=OS X,arch=x86_64" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
