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

	var audioEngine = AVAudioEngine()
	let itemID = NSTouchBarItem.Identifier(rawValue: "com.addisonhanrattie.visualizer.color")
	var vol : Volume = Volume()
	var throwAway = 0
	
	var colorSKView = ColorView()
	
	var useBlackHole = true
	var manipulatingDevices = false
	var ignore = false
	
	var prevInp: String?
	var aggregateDeviceID: AudioDeviceID?
	
	// MARK: UI
	
	@IBOutlet var progressCircle: NSProgressIndicator!
	@IBOutlet var progressCircle2: NSProgressIndicator!
	
	@IBOutlet var levelDisplay: NSLevelIndicator!
	
	@IBAction func soundSource(_ sender: Any) {
		useBlackHole = !useBlackHole
		if useBlackHole {
			stop()
			createAudioDevice()
			setup()
		} else {
			stop()
			print(deleteMultiOutputAudioDevice())
			setup()
		}
	}
	
	// MARK: Loading/Unloading
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Register for audio changes
		// swiftlint:disable line_length
		addListenerBlock(listenerBlock: audioObjectPropertyListenerBlock, onAudioObjectID: AudioObjectID(kAudioObjectSystemObject), forPropertyAddress: AudioObjectPropertyAddress( mSelector: kAudioHardwarePropertyDefaultOutputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster))
		addListenerBlock(listenerBlock: audioObjectPropertyListenerBlock, onAudioObjectID: AudioObjectID(kAudioObjectSystemObject), forPropertyAddress: AudioObjectPropertyAddress( mSelector: kAudioHardwarePropertyDefaultInputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster))
		// swiftlint:enable line_length
		
		createAudioDevice()
		
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
	
	override func viewDidAppear() {
		backGroundShow()
	}
	
	// swiftlint:disable line_length
	deinit {
		deleteListener(listenerBlock: audioObjectPropertyListenerBlock, onAudioObjectID: AudioObjectID(kAudioObjectSystemObject), forPropertyAddress: AudioObjectPropertyAddress( mSelector: kAudioHardwarePropertyDefaultOutputDevice, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster))
	}
	
	// MARK: Notification Subscribers
	
	// REF: https://stackoverflow.com/questions/43848002/audioobjectaddpropertylistenerblock-not-called-in-swift-3, https://stackoverflow.com/questions/26070058/how-to-get-notification-if-system-preferences-default-sound-changed
	func addListenerBlock( listenerBlock: @escaping AudioObjectPropertyListenerBlock, onAudioObjectID: AudioObjectID, forPropertyAddress: AudioObjectPropertyAddress) {
		var forPropertyAddress = forPropertyAddress

		let status = AudioObjectAddPropertyListenerBlock(onAudioObjectID, &forPropertyAddress, nil, listenerBlock)
		print(status)
	}
	// swiftlint:enable line_length
	
	func deleteListener( listenerBlock: @escaping AudioObjectPropertyListenerBlock, onAudioObjectID: AudioObjectID, forPropertyAddress: AudioObjectPropertyAddress) {
		var forPropertyAddress = forPropertyAddress
		
		AudioObjectRemovePropertyListenerBlock(onAudioObjectID, &forPropertyAddress, nil, listenerBlock)
	}
	
	// MARK: Touch Bar
	
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

	func setup(){
		audioEngine = AVAudioEngine()
		
		// Check For Device
		let format = audioEngine.inputNode.outputFormat(forBus: 0)

		print(format)
		vol.sampleRate = audioEngine.inputNode.outputFormat(forBus: 0).sampleRate
		
		// Install Tap and Start Audio Processing // Try Larger Buffer Size to test affects
		audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) in
			let levels = self.vol.analyze(buffer: buffer)
			
			self.colorSKView.colScene.levelForAll(levels: levels.0.reversed())
			
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
	
	// MARK: Audio Managment

	func createAudioDevice() {
		// Find all audio devices and verify their existence
		guard var systemDefault = AudioDevice.defaultOutputDevice() else {
			fatalError("There was no default system audio device detected, this is weird")
		}
		guard let blackHole = AudioDevice.lookup(by: "BlackHole2ch_UID") else {
			return
		}
		
		// Deconstruct the Previous Agg Dev If It Existed
		if let aggDev = AudioDevice.lookup(by: "TBV Aggregate Device UID") {
			aggregateDeviceID = aggDev.id
			if systemDefault.id == aggDev.id {
				for devID in aggDev.ownedObjectIDs()! {
					// Look for the underlying output attached to the Agg Device
					let dev = AudioDevice.lookup(by: devID)!
					if dev.uid != "BlackHole2ch_UID" && dev.layoutChannels(direction: .playback) ?? 0 >= 1 {
						systemDefault = AudioDevice.lookup(by: dev.uid!)!
//						systemDefault.setAsDefaultOutputDevice() // Set to output to stop phantom audio drivers?
						break
					}
				}
			}
			print(deleteMultiOutputAudioDevice())
		}
		
		// Set BlackHole Volume to Max
		blackHole.setVolume(1.0, channel: 0, direction: .recording)
		blackHole.setVolume(1.0, channel: 1, direction: .recording)
		blackHole.setVolume(1.0, channel: 2, direction: .recording)
		blackHole.setVolume(1.0, channel: 0, direction: .playback)
		blackHole.setVolume(1.0, channel: 1, direction: .playback)
		blackHole.setVolume(1.0, channel: 2, direction: .playback)
		
		// Make sure we are all working at the same sample rate
		blackHole.setNominalSampleRate(48000)
		systemDefault.setNominalSampleRate(48000)
		
		// Create the Agg Dev
		let ret = createMultiOutputAudioDevice(masterDeviceUID: systemDefault.uid! as CFString, secondDeviceUID: blackHole.uid! as CFString, multiOutUID: "TBV Aggregate Device UID")
		print(ret.0)
		
		// Set As Default
		aggregateDeviceID = ret.1
		AudioDevice.lookup(by: ret.1)?.setAsDefaultOutputDevice()
		blackHole.setAsDefaultInputDevice()
	}
	
	func stop(){ // End tapping of audio engine
		audioEngine.inputNode.removeTap(onBus: 0)
		audioEngine.stop()
	}
	
	func audioObjectPropertyListenerBlock (numberAddresses: UInt32, addresses: UnsafePointer<AudioObjectPropertyAddress>) {
		var index: UInt32 = 0
		while index < numberAddresses {
			let address: AudioObjectPropertyAddress = addresses[Int(index)]
			switch address.mSelector {
			case kAudioHardwarePropertyDefaultOutputDevice:
				let device = AudioDevice.defaultOutputDevice()
				print("kAudioHardwarePropertyDefaultOutputDevice: \(device)")
				
				// Tear down previous init and rebuild audio device with new source
				if device?.uid != "TBV Aggregate Device UID" && useBlackHole {
					// check if the user is switching to the outer device and if so do not correct
					for devID in AudioDevice.lookup(by: "TBV Aggregate Device UID")?.ownedObjectIDs() ?? [] { // If no device is found don't run loop
						let dev = AudioDevice.lookup(by: devID)!
						if dev.uid == device?.uid {
							return
						}
					}
					
					stop()
					createAudioDevice()
				// If we switched to the agg device update the input by calling setup
				} else if useBlackHole {
					setup()
				// If the output was switched and no black hole simply update the audio engine
				} else {
					stop()
					setup()
				}
			case kAudioHardwarePropertyDefaultInputDevice:
				// If the system input changes reload the audio engine
				stop()
				setup()
			default:
				print("We didn't expect this!")
			}
			index += 1
		}
	}

}

// MARK: Aggregate Device Creation Extension
extension ViewController {
	// REF: https://stackoverflow.com/questions/35469569/how-can-i-programmatically-create-a-multi-output-device-in-os-x
	func createMultiOutputAudioDevice(masterDeviceUID: CFString, secondDeviceUID: CFString, multiOutUID: String) -> (OSStatus, AudioDeviceID) {
		let desc: [String : Any] = [
			kAudioAggregateDeviceNameKey: "TBV Output",
			kAudioAggregateDeviceUIDKey: multiOutUID,
			kAudioAggregateDeviceSubDeviceListKey: [[kAudioSubDeviceUIDKey: masterDeviceUID], [kAudioSubDeviceUIDKey: secondDeviceUID]],
			kAudioAggregateDeviceMasterSubDeviceKey: masterDeviceUID,
			kAudioAggregateDeviceIsStackedKey: 1,
			]

		var aggregateDevice: AudioDeviceID = 0
		return (AudioHardwareCreateAggregateDevice(desc as CFDictionary, &aggregateDevice), aggregateDevice)
	}
	
	func deleteMultiOutputAudioDevice() -> OSStatus { //AudioDeviceIOProc
		if aggregateDeviceID != nil {
			let ret = AudioHardwareDestroyAggregateDevice(aggregateDeviceID!)
			print(AudioHardwareUnload())
			return ret
		} else {
			return OSStatus(-13.0)
		}
	}
	
	func updateMultiOutputAudioDeviceID() -> Bool {
		aggregateDeviceID = AudioDevice.lookup(by: "TBV Aggregate Device UID")?.id
		return aggregateDeviceID != nil
	}
}

// MARK: Touch Bar Responder
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
		NSTouchBar.presentSystemModalTouchBar(touchBar, systemTrayItemIdentifier: identifier)
	}

	func presentSystemModal(_ touchBar: NSTouchBar!, placement: Int64, systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier!) {
		NSTouchBar.presentSystemModalTouchBar(touchBar, placement: placement, systemTrayItemIdentifier: identifier)
	}

	func minimizeSystemModal(_ touchBar: NSTouchBar!) {
		NSTouchBar.minimizeSystemModalTouchBar(touchBar)
	}
}

// MARK: CoreAudio Notification Responder
extension ViewController: EventSubscriber { // bug in AMCoreAudio or something so code here is dead
	func eventReceiver(_ event: Event) {
		switch event {
		case let event as AudioHardwareEvent:
			switch event {
			case let .defaultOutputDeviceChanged(audioDevice):
			// Recreate the audio engine with the new mapping to maintain sourcing and optionally reconfigure aggregate device
				print("Default output device changed to \(audioDevice)")
				if audioDevice.uid != "TBV Aggregate Device UID" && useBlackHole {
					// Tear down previous init and rebuild audio device with new source
					
					stop()
					createAudioDevice()
					setup()
				}
				if !useBlackHole {
					stop()
					setup()
				}
			case let .defaultInputDeviceChanged(audioDevice: audioDevice):
				print("Default input device changed to \(audioDevice)")
				if !useBlackHole && audioDevice.uid != prevInp {
					stop()
					setup()
				}
				prevInp = audioDevice.uid // is this even necessary?
			default:
				break
			}
		default:
			break
		}
	}
}
