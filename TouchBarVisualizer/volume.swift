//
//  volume.swift
//  TouchBarVisualizer
//
//  Created by Addison Hanrattie on 4/24/19.
//  Copyright © 2019 Addison Hanrattie. All rights reserved.
//

import Cocoa
import AVFoundation
import Accelerate

public class volume {
    
    public var sampleRate = 0.0
    
    let col : colorView = colorView()
    
    public func analyze(buffer: AVAudioPCMBuffer) -> [Int] {
        // refrenced from stackoverflow.com/questions/3398753/using-the-apple-fft-and-accelerate-framework
        
        // TODO : Needs to have input device auto set
        // Set Buffers
        let bufferSize = buffer.frameLength
        
        let sqLog = vDSP_Length(log2(Float(bufferSize)))
        var setup : FFTSetup? = vDSP_create_fftsetup(sqLog, FFTRadix(kFFTRadix2))! // Change value for
        
        let maxBufFloatL = Int(bufferSize / 2) * MemoryLayout<Float>.size
        
        // Set Comnplex
        var realp = (malloc(maxBufFloatL)?.assumingMemoryBound(to: Float.self))!
        var imagp = (malloc(maxBufFloatL)?.assumingMemoryBound(to: Float.self))!
        var complex = DSPSplitComplex(realp: realp, imagp: imagp)
        
        // Control Memory
        defer {
            vDSP_destroy_fftsetup(setup)
            realp.deallocate()
            imagp.deallocate()
        }

        // even odds
        var cPnt = buffer.audioBufferList.pointee.mBuffers.mData!.assumingMemoryBound(to: DSPComplex.self)
        var cPntLen = buffer.audioBufferList.pointee.mBuffers.mDataByteSize
        vDSP_ctoz(cPnt, 2, &complex, 1, vDSP_Length(bufferSize / 2))
        memset(cPnt, 0, Int(cPntLen))
        
        //fft and clear
        vDSP_fft_zrip(setup!, &complex, 1, sqLog, FFTDirection(FFT_FORWARD))
        bzero(complex.imagp, maxBufFloatL)

        
        
        
        var row : vDSP_Length = 0
        var vol : Float = 0.0
        vDSP_maxvi(complex.realp, 1, &vol, &row, vDSP_Length(bufferSize / 2))
//        print(row, vol)
        
        // NTS: This should probably be asynced to release the data ??? //nvm i think
        
        var peaks : [Float] = []
        
        let kDivCons : Float = 1.035
        var topRng = 2205
        var btmRng = Int(Float(topRng) / kDivCons) // 1.25 is a constant which may need tunning // Another note 1.25 is way too big so if u see this it needs to be smaller
        
        topRng = Int(Float(topRng) / kDivCons) //Constant^
        btmRng = Int(Float(topRng) / kDivCons) //Constant^
        
        for i in 1...100 { //NTS split trebel levels from bass levels
//            print(topRng, btmRng)
            var avgPeak : Float = 0.0
//            vDSP_meam[gv((complex.realp + topRng), 1, &avgPeak, vDSP_Length(topRng - btmRng))
//            vDSP_measqv((complex.realp + topRng), 1, &avgPeak, vDSP_Length(topRng - btmRng))
//            vDSP_rmsqv((complex.realp + topRng), 1, &avgPeak, vDSP_Length(topRng - btmRng))
            vDSP_maxmgv((complex.realp + topRng), 1, &avgPeak, vDSP_Length(topRng - btmRng))
            
            
            topRng = Int(Float(topRng) / kDivCons) //Constant^
            btmRng = Int(Float(topRng) / kDivCons) //Constant^
            
            if avgPeak.isNaN {
                avgPeak = 0.0
            } else if avgPeak.isInfinite {
                avgPeak = 300.0
            }
            
            
            peaks.append(avgPeak)
        }
        
//        print(peaks)
        
        let method = 2
        var finalPeaks : [Int] = []
        
        switch method {
        case 0:
            let shifter = 10.0 / (peaks.max() ?? 1.0)
            
            print(peaks.max(), shifter)
            for i in 0...99 {
                if shifter.isInfinite || shifter.isNaN {
                    let peak = Int(peaks[i] * 0.0) + 1
                    finalPeaks.append(peak)
                } else {
                    let peak = Int(peaks[i] * shifter) + 1
                    finalPeaks.append(peak)
                }
            }
        case 1:
            let sortedPeaks = peaks.sorted()
            
            for i in 0...99 {
                let p = sortedPeaks.firstIndex(of: peaks[i])!
                do {
                    switch Float(p) / 99.0 {
                    case 0.9...1.0:
                        finalPeaks.append(10)
                    case 0.8..<0.9:
                        finalPeaks.append(9)
                    case 0.7..<0.8:
                        finalPeaks.append(8)
                    case 0.6..<0.7:
                        finalPeaks.append(7)
                    case 0.5..<0.6:
                        finalPeaks.append(6)
                    case 0.4..<0.5:
                        finalPeaks.append(5)
                    case 0.3..<0.4:
                        finalPeaks.append(4)
                    case 0.2..<0.3:
                        finalPeaks.append(3)
                    case 0.1..<0.2:
                        finalPeaks.append(2)
                    case 0.0..<1.0:
                        finalPeaks.append(1)
                    default:
                        finalPeaks.append(0)
                        print("error occured index out of bounds")
                    }
                    
                }
                /*do {
                    switch Float(p) / 43.0 {
                    case 0.85...1.0:
                        finalPeaks.append(4)
                    case 0.5..<0.85:
                        finalPeaks.append(3)
                    case 0.15..<0.5:
                        finalPeaks.append(2)
                    case 0.0..<0.15:
                        finalPeaks.append(1)
                    default:
                        print("error occured index out of bounds")
                    }
                }*/
            }
        case 2:
            peaks.max()
            let s = powf(peaks.max()!, 0.1)
            for i in 0...99 {
//                print(peaks[i])
                if peaks[i] == 0.0 {
                    finalPeaks.append(0)
                    continue
                }
                var peak = logA(x: peaks[i], ofBase: s)
                if peak < 0.0 {
                    peak = 0.0
                }
                finalPeaks.append(Int(peak))
            }
        default:
            fatalError()
            break
        }
        
        //NTS: I have written a couple different ways of scalling the volume
        
        // Clear Data
        for ii in 0..<Int(buffer.audioBufferList.pointee.mNumberBuffers) {
            bzero(buffer.audioBufferList.pointee.mBuffers.mData! + ii, Int(buffer.audioBufferList.pointee.mBuffers.mDataByteSize))
        }
        
        return finalPeaks
    }
    
    func logA(x: Float, ofBase b: Float) -> Float {
        return log(x)/log(b)
    }
}


/* Memory Leak Diagnostic info
Currently losing mem at about 0.02mb/s should be patched but very small - likely in a malloc?
*/
