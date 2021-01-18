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
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
		vc.stop()
		print("found device for deletion \(vc.updateMultiOutputAudioDeviceID())")
		print(vc.deleteMultiOutputAudioDevice())
		print("closed")
	}
}

