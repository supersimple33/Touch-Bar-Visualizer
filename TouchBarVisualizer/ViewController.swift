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
        
        
        // For guarenteeing max volume.
        var defaultOutputDeviceID = AudioDeviceID(0) //from stackoverflow.com/questions/2729 0751/using-audiotoolbox-from-swift-to-access-os-x-master-volume
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
        
        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &getDefaultOutputDevicePropertyAddress, 0, nil, &defaultOutputDeviceIDSize, &defaultOutputDeviceID)
        var volume = Float32(1.0)
        let volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
        
        var volumePropertyAddress = AudioObjectPropertyAddress(mSelector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume, mScope: kAudioDevicePropertyScopeOutput, mElement: kAudioObjectPropertyElementMaster)
        AudioObjectSetPropertyData(defaultOutputDeviceID, &volumePropertyAddress, 0, nil, volumeSize, &volume)
        
        var volumePropertyAddressInput = AudioObjectPropertyAddress(mSelector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume, mScope: kAudioDevicePropertyScopeInput, mElement: kAudioObjectPropertyElementMaster)
        AudioObjectSetPropertyData(defaultOutputDeviceID, &volumePropertyAddressInput, 0, nil, volumeSize, &volume)
        
        
        
        createAudioDevice()
        
//        setup()
        
    }
    
    //  NullAudio_WillDoIOOperation
    func createAudioDevice() {
        
        let systemDefault = AudioDevice.defaultOutputDevice()
        guard let soundFlower = AudioDevice.lookup(by: "SoundflowerEngine:0") else {
            fatalError("Soundflower not installed") // better error handling
        }
        
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



