//
//  GraphAverageData.swift
//  Apercu
//
//  Created by David Lantrip on 1/16/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import Accelerate

func averageRawData(bpm: [Double], time: [Double], minTime: Double, maxTime: Double) -> [[Double]] {

    var finalTime = time
    var temporaryTime = time
    var minimum = minTime
    var negatedMaximum = -1 * maxTime
    let length = vDSP_Length(temporaryTime.count)
    vDSP_vthresD(temporaryTime, 1, &minimum, &temporaryTime, 1, length)
    vDSP_vnegD(temporaryTime, 1, &temporaryTime, 1, length)
    vDSP_vthresD(temporaryTime, 1, &negatedMaximum, &temporaryTime, 1, length)
    vDSP_vcmprsD(finalTime, 1, temporaryTime, 1, &finalTime, 1, length)
    var countInRange = finalTime.count;
    print(countInRange)

//    if countInRange < 750 {
    if countInRange < 20 {
        return [bpm, time]
    } else {
        var numberOfIterations = 1

//        while countInRange > 750 {
        while countInRange / (2 * numberOfIterations) > 20 {
            ++numberOfIterations
        }

        var outputArray = [bpm, time]

        for _ in 0..<numberOfIterations {
            outputArray = halfBpmData(outputArray)
        }

        return outputArray
    }
}

func halfBpmData(input: [[Double]]) -> [[Double]] {
    var bpm: [Double] = input.first!
    var time: [Double] = input.last!
    
    var outputBpm: [Double]!
    var outputTime: [Double]!
    
    if bpm.count % 2 == 0 {
        outputBpm = [Double](count: bpm.count / 2, repeatedValue: 0.0)
        outputTime = [Double](count: time.count / 2, repeatedValue: 0.0)
        
        var outputIndex = 0
        for var i = 0; i < bpm.count; i += 2 {
            outputBpm[outputIndex] = (bpm[i] + bpm[i + 1]) / 2
            outputTime[outputIndex] = (time[i] + time[i + 1]) / 2
            ++outputIndex
        }
        
    } else {
        outputBpm = [Double](count: bpm.count / 2 + 1, repeatedValue: 0.0)
        outputTime = [Double](count: time.count / 2 + 1, repeatedValue: 0.0)
        
        var outputIndex = 0
        for var i = 0; i < bpm.count - 1; i += 2 {
            outputBpm[outputIndex] = (bpm[i] + bpm[i + 1]) / 2
            outputTime[outputIndex] = (time[i] + time[i + 1]) / 2
            ++outputIndex
        }
        
        outputBpm[outputIndex] = bpm.last!
        outputTime[outputIndex] = time.last!

    }
    
    return [outputBpm, outputTime]
}