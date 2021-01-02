//
//  VolumeTests.swift
//  TouchBarVisualizerTests
//
//  Created by Addison Hanrattie on 1/2/21.
//  Copyright © 2021 Addison Hanrattie. All rights reserved.
//

import XCTest
import AVFoundation
@testable import TouchBarVisualizer

// TODO: create error struct

class VolumeTests: XCTestCase {
    var vol : Volume!
    var buffer : AVAudioPCMBuffer!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        vol = Volume()
        
        // Create and Configure Audio Buffer
        guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000.0, channels: 2, interleaved: false) else {
            return // TODO: this should throw instead
        }
        buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 4800)
        buffer.frameLength = 4800
        
        // Assign random floats to the buffer data
        for i in 0..<Int(buffer.frameLength) {
            buffer.floatChannelData?.advanced(by: 0).pointee.advanced(by: i).pointee = Float.random(in: 0.0...1.0)
        }
        for i in 0..<Int(buffer.frameLength) {
            buffer.floatChannelData?.advanced(by: 1).pointee.advanced(by: i).pointee = Float.random(in: 0.0...1.0)
        }
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        vol = nil
        buffer = nil
    }

    func testAnalyze() throws {
        let ret = vol.analyze(buffer: buffer)
        
        // Percent of peak should be in 0...10
        XCTAssertGreaterThanOrEqual(ret.1, 0, "Percent of Peak was below the range") //, file: "Volume.swift", line: 20)
        XCTAssertLessThanOrEqual(ret.1, 10, "Percent of Peak was below the range") //, file: "Volume.swift", line: 20)
        
        // Check number of levels
        XCTAssertEqual(ret.0.count, 100, "Unexpected Count For Levels") //, file: "Volume.swift", line: 20)
        
        // Check all levels are in 0...10
        for elem in ret.0 {
            XCTAssertGreaterThanOrEqual(elem, 0, "One of the levels was below the range") //, file: "Volume.swift", line: 20)
            XCTAssertLessThanOrEqual(elem, 10, "One of the levels was above the range") //, file: "Volume.swift", line: 20)
        }
        
        // Check Performance of analyze
        let options = XCTMeasureOptions.default
        options.iterationCount = 50
        self.measure(metrics: [XCTClockMetric(), XCTCPUMetric()], options: options) {
            let t = vol.analyze(buffer: buffer)
            vol.analyze(buffer: buffer)
            vol.analyze(buffer: buffer)
            vol.analyze(buffer: buffer)
        }
    }
}
