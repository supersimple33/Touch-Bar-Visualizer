//
//  ViewController.swift
//  TouchBarVisualizer
//
//  Created by Addison Hanrattie on 4/21/19.
//  Copyright © 2019 Addison Hanrattie. All rights reserved.
//

import Cocoa
import AVFoundation
import Accelerate
import AudioToolbox
import SpriteKit
import CoreAudio
import AMCoreAudio

class ViewController: NSViewController {

	let audioEngine = AVAudioEngine()
	let itemID = NSTouchBarItem.Identifier(rawValue: "com.addisonhanrattie.visualizer.color")
	var vol : Volume = Volume()
	var throwAway = 0
	
	var colorSKView = ColorView()
	let newAuds : NewAudioDevice = NewAudioDevice()
	
	@IBOutlet var progressCircle: NSProgressIndicator!
	@IBOutlet var progressCircle2: NSProgressIndicator!
	
	@IBOutlet var levelDisplay: NSLevelIndicator!
	
//	@IBAction func show(_ sender: Any) {
//		stop()
//		newAuds.destroyAggDevice()
//	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		createAudioDevice()
		setup()
		
		NotificationCenter.defaultCenter.subscribe(self, eventType: AudioHardwareEvent.self, dispatchQueue: DispatchQueue.main)
		
		Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { (tm) in
			if self.progressCircle.doubleValue == self.progressCircle.maxValue {
				self.progressCircle.doubleValue = 0.0
				self.progressCircle2.doubleValue = 0.0
			} else {
				self.progressCircle.increment(by: 0.1)
				self.progressCircle2.increment(by: 0.1)
			}
		}
	}
	
	deinit {
		NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioHardwareEvent.self)
	}
	
	override func viewDidAppear() {
		backGroundShow()
	}
	
	func updatePresence() {
		DFRElementSetControlStripPresenceForIdentifier(itemID, true)
	}
	
	@objc func showTouchBar() {
		presentSystemModal(touchBar, systemTrayItemIdentifier: itemID)
		updatePresence()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.colorSKView.presentColor()
		}
		//plug in show here
	}
	
	func backGroundShow() {
		DFRSystemModalShowsCloseBoxWhenFrontMost(false)
		let item = NSCustomTouchBarItem(identifier: itemID)
		let nmg = NSImage(named: NSImage.Name("Logo"))! //Create Better Image
		item.view = NSButton(image: nmg, target: self, action: #selector(showTouchBar))
		NSTouchBarItem.addSystemTrayItem(item)
		updatePresence()
	}
	
	func createAudioDevice() {
		
		// Find all audio devices and verify their existence
		guard var systemDefault = AudioDevice.defaultOutputDevice() else {
			fatalError("There was no default system audio device detected")
		}
		guard let blackHole = AudioDevice.lookup(by: "BlackHole2ch_UID") else {
			fatalError("BlackHole not installed: install blackhole or manipulate source code for other inputs") // add better error handling
		}
		
		// Deconstruct the Previous Agg Dev If It Existed
		if let aggDev = AudioDevice.lookup(by: "TBV Aggregate Device") {
			newAuds.setAggDeviceID(aggDev.id)
			if systemDefault.id == aggDev.id {
				for devID in aggDev.ownedObjectIDs()! {
					// Look for the underlying output attached to the Agg Device
					let dev = AudioDevice.lookup(by: devID)!
					if dev.uid != "BlackHole2ch_UID" && dev.layoutChannels(direction: .playback) ?? 0 >= 1 {
						systemDefault = AudioDevice.lookup(by: dev.uid!)!
						break
					}
				}
			}
			newAuds.destroyAggDevice()
		}
		
		// Set BlackHole Volume to Max
		blackHole.setVolume(1.0, channel: 0, direction: .recording)
		blackHole.setVolume(1.0, channel: 1, direction: .recording)
		blackHole.setVolume(1.0, channel: 2, direction: .recording)
		blackHole.setVolume(1.0, channel: 0, direction: .playback)
		blackHole.setVolume(1.0, channel: 1, direction: .playback)
		blackHole.setVolume(1.0, channel: 2, direction: .playback)
		
		// Create A List of Devices for the Agg Dev
		let devices=[[kAudioSubDeviceUIDKey as CFString:systemDefault.uid! as CFString] as CFDictionary, [kAudioSubDeviceUIDKey as CFString: blackHole.uid! as CFString] as CFDictionary] as CFArray
		
		// Create the Agg Dev
		newAuds.newAggDevice(devices, blackHole.id)
	}

	func setup(){
		// Check For Device
		let format = audioEngine.inputNode.outputFormat(forBus: 0)
		guard format.channelCount == 2 else {
			fatalError() // Should never be run should be removed
		}

		print(format)
		vol.sampleRate = audioEngine.inputNode.outputFormat(forBus: 0).sampleRate
		
		// Install Tap and Start Audio Processing // Try Larger Buffer Size to test affects
		audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) in
			let levels = self.vol.analyze(buffer: buffer)
			for i in 0...99 {
				// Displaying
				self.colorSKView.colScene.levelFor(group: 99 - i, level: levels.0[i])
			} // Removed throttling code may impact performance
			print(levels.1)
			DispatchQueue.main.async {
				self.levelDisplay.doubleValue = Double(levels.1)
			}
		}
		
		// Starting Audio Engine
		audioEngine.prepare()
		do {
			try audioEngine.start()
		} catch {
			print(error)
		}
	}

	func stop(){ // End tapping of audio engine
		audioEngine.inputNode.removeTap(onBus: 0)
		audioEngine.stop()
	}

}

@available(OSX 10.12.2, *)
extension ViewController: NSTouchBarDelegate {
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self
		touchBar.customizationIdentifier = "com.addisonhanrattie.visualizer"
		touchBar.defaultItemIdentifiers = [itemID]
		touchBar.customizationAllowedItemIdentifiers = [itemID]
		return touchBar
	}
	
	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		
		let item = NSCustomTouchBarItem(identifier: itemID)
		colorSKView = ColorView()
		item.view = colorSKView
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.colorSKView.presentText()
		}
		return item
	}

	func presentSystemModal(_ touchBar: NSTouchBar!, systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier!) {
		NSTouchBar.presentSystemModalTouchBar(touchBar, systemTrayItemIdentifier: identifier)	}

	func presentSystemModal(_ touchBar: NSTouchBar!, placement: Int64, systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier!) {
		NSTouchBar.presentSystemModalTouchBar(touchBar, placement: placement, systemTrayItemIdentifier: identifier)
	}

	func minimizeSystemModal(_ touchBar: NSTouchBar!) {
		NSTouchBar.minimizeSystemModalTouchBar(touchBar)
	}
}

extension ViewController: EventSubscriber {
	func eventReceiver(_ event: Event) {
		switch event {
		case let event as AudioHardwareEvent:
			switch event {
			case let .defaultOutputDeviceChanged(audioDevice):
				print("Default output device changed to \(audioDevice)")
				if audioDevice.uid! != "TBV Aggregate Device" {
					// Tear down previous init and rebuild audio device with new source
					stop()
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
						self.createAudioDevice()
						self.setup()
					}
				}
			default:
				break
			}
		default:
			break
		}
	}
}
