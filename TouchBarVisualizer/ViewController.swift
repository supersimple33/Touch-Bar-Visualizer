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
    var file : AVAudioFile!
    var vol : volume = volume()
    var throwAway = 0
    
    let colorSKView = colorView()
    let newAuds : NewAudioDevice = NewAudioDevice()
    
    @IBOutlet var bar: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAudioDevice()
        
//        setup()
        
    }
    
    //  NullAudio_WillDoIOOperation
    func createAudioDevice() {
        
        let systemDefault = AudioDevice.defaultOutputDevice()
        guard let soundFlower = AudioDevice.lookup(by: "SoundflowerEngine:0") else {
            fatalError("Soundflower not installed") // better error handling
        }
        
        soundFlower.setVolume(1.0, channel: 0, direction: .recording)
        soundFlower.setVolume(1.0, channel: 1, direction: .recording)
        soundFlower.setVolume(1.0, channel: 2, direction: .recording)
        
        soundFlower.setVolume(1.0, channel: 0, direction: .playback)
        soundFlower.setVolume(1.0, channel: 1, direction: .playback)
        soundFlower.setVolume(1.0, channel: 2, direction: .playback)
        
        let devices = [[kAudioSubDeviceUIDKey as CFString : (systemDefault?.uid)! as CFString] as CFDictionary, [kAudioSubDeviceUIDKey as CFString: soundFlower.uid! as CFString] as CFDictionary] as CFArray
        
        newAuds.newAggDevice(devices)
    }

    func setup(){
        let format = audioEngine.inputNode.outputFormat(forBus: 0)
        guard format.channelCount == 2 else {
            fatalError() // Better error handling
        }
        let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("record.wav")
        do {
//            try FileManager.default.removeItem(at: url)
            let settings = audioEngine.inputNode.outputFormat(forBus: 0).settings
//            file = try AVAudioFile(forWriting: url, settings: settings)
            file = try AVAudioFile(forWriting: url, settings: settings, commonFormat: format.commonFormat, interleaved: format.isInterleaved)
        } catch {
            print(error)
        }

        print(format)
        //        audioEngine.connect(audioEngine.inputNode, to: audioEngine.mainMixerNode, format: format)
        
        vol.sampleRate = audioEngine.inputNode.outputFormat(forBus: 0).sampleRate
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) in
            if self.throwAway == 0 {
                self.throwAway = 0
                let levels = self.vol.analyze(buffer: buffer)
                for i in 0...99 {
                    self.colorSKView.colScene.levelFor(group: i, level: levels[i])
                }
                
            } else {
                self.throwAway += 1
            }
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print(error)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
            self.stop()
        }

    }

    func stop(){
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        file = nil
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



