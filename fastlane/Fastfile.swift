// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    
//    func beforeAll() {
//        deliver(platform: "mac")
//        setupCircleCi()
//        match(type: "development")
//        environmentVariable(set: ["MATCH_GIT_URL" : "https://github.com/supersimple33/certificates.git"])
////        ENV["MATCH_GIT_URL"] = "https://github.com/supersimple33/certificates"
//    }
    
	func checkLane() {
        desc("Run code checks")
//        deliver(platform: "macos")
        setupCircleCi()
        environmentVariable(set: ["GIT_URL" : "https://github.com/supersimple33/certificates.git"])
        match(type: "development")
		// add actions here: https://docs.fastlane.tools/actions
        swiftlint(path:"TouchBarVisualizer") //,  ignoreExitStatus: true, raiseIfSwiftlintError: false
        swiftlint(path:"TouchBarVisualizerTests")
        scan(workspace: "TouchBarVisualizer.xcworkspace", scheme: "TouchBarVisualizer")
	}
}
