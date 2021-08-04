//
//  AppDelegate.swift
//  TouchBarVisualizer
//
//  Created by Addison Hanrattie on 4/12/19.
//  Copyright © 2019 Addison Hanrattie. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	let vc : ViewController = ViewController()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		if #available(OSX 10.12.2, *) {
			NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
		}
		
		guard let releaseURL = URL(string: "https://api.github.com/repos/supersimple33/Touch-Bar-Visualizer/releases/latest") else {
			print("We should never fail to create url")
			return
		}
		do {
			let html = try Data(contentsOf: releaseURL)
			let htmlJson = try JSONSerialization.jsonObject(with: html, options: [])
			if let htmlDict = htmlJson as? [String : Any] {
				if let tag = htmlDict["tag_name"] as? String {
					if tag > "v0.3.1" {
						let alert = NSAlert()
						alert.messageText = "There is a newer version of TBV available"
						alert.runModal()
					}
				}
			} else {
				print("Failed to cover JSON")
			}
		} catch let error {
			print(error)
		}
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
		vc.stop()
		print("found device for deletion \(vc.updateMultiOutputAudioDeviceID())")
		print(vc.deleteMultiOutputAudioDevice())
		print("closed")
	}
}

