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
    var vol : volume = volume()
    var throwAway = 0
    
    let colorSKView = colorView()
    let newAuds : NewAudioDevice = NewAudioDevice()
    
    @IBOutlet var progressCircle: NSProgressIndicator!
    @IBOutlet var progressCircle2: NSProgressIndicator!
    
    @IBOutlet var levelDisplay: NSLevelIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAudioDevice()
        setup()
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
    
//    override func viewDidAppear() {
////        view.window?.level = .floating
//    }
    
    func createAudioDevice() {
        
        // Find all audio devices
        let systemDefault = AudioDevice.defaultOutputDevice()
        guard let soundFlower = AudioDevice.lookup(by: "SoundflowerEngine:0") else {
            fatalError("Soundflower not installed") // better error handling
        }
        
        // Set max Volume
        soundFlower.setVolume(1.0, channel: 0, direction: .recording)
        soundFlower.setVolume(1.0, channel: 1, direction: .recording)
        soundFlower.setVolume(1.0, channel: 2, direction: .recording)
        soundFlower.setVolume(1.0, channel: 0, direction: .playback)
        soundFlower.setVolume(1.0, channel: 1, direction: .playback)
        soundFlower.setVolume(1.0, channel: 2, direction: .playback)
        
        let devices = [[kAudioSubDeviceUIDKey as CFString : (systemDefault?.uid)! as CFString] as CFDictionary, [kAudioSubDeviceUIDKey as CFString: soundFlower.uid! as CFString] as CFDictionary] as CFArray
        
        newAuds.newAggDevice(devices, soundFlower.id)
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
                self.colorSKView.colScene.levelFor(group: 99 - i, level: levels.0[i]) // Displaying
            } // Removed throttling code may impact performance
//            print(levels.1)
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

//        DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
//            self.stop()
//        }

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
        item.view = colorSKView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.colorSKView.present()
        }
        return item
    }
}



