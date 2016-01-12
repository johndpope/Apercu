//
//  GraphMostActive.swift
//  Apercu
//
//  Created by David Lantrip on 1/1/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import Accelerate

class GraphMostActive {
    
    func mostActivePeriod(bpm: [Double], times: [Double], duration: Double, completion: (timeOne: Double, timeTwo: Double) -> Void) {
        
        var currentMax: Double = 0
        var index = 0
        
        var maxIndexStart = 0
        var maxIndexEnd = 0
        
        let timeVector1 = Array(times[1..<times.count])
        let timeVector2 = Array(times[0..<(times.count - 1)])
        var deltaTime = [Double](count: timeVector1.count, repeatedValue: 0.0)
        vDSP_vsubD(timeVector2, 1, timeVector1, 1, &deltaTime, 1, vDSP_Length(timeVector1.count))
        
        let bpmVector1 = Array(bpm[1..<bpm.count])
        let bpmVector2 = Array(bpm[0..<(bpm.count - 1)])
        var bpmAverageVector = [Double](count: bpmVector1.count, repeatedValue: 0.0)
        var bpmXtime = [Double](count: bpmVector1.count, repeatedValue: 0.0)
        var two: Double = 2.0
        vDSP_vaddD(bpmVector1, 1, bpmVector2, 1, &bpmAverageVector, 1, vDSP_Length(bpmVector1.count))
        vDSP_vsdivD(bpmAverageVector, 1, &two, &bpmAverageVector, 1, vDSP_Length(bpmVector1.count))
        
        // Average of the two samples multiplied by the duration 
        vDSP_vmulD(bpmAverageVector, 1, deltaTime, 1, &bpmXtime, 1, vDSP_Length(bpmVector1.count))
        
        while index < bpmXtime.count {
            var currentTotal = bpmXtime[index]
            var timeTotal = deltaTime[index]
            var subIndex = 1
            
            while (index + subIndex) < bpmXtime.count && timeTotal < duration {
                if timeTotal + deltaTime[index + subIndex] < duration {
                    currentTotal += bpmXtime[index + subIndex]
                }
                timeTotal += deltaTime[index + subIndex]
                ++subIndex
            }
            
            --subIndex
            
            if currentTotal > currentMax {
                currentMax = currentTotal
                maxIndexStart = index + 1
                maxIndexEnd = index + subIndex + 1
            }
            
            ++index
        }
            
        completion(timeOne: times[maxIndexStart], timeTwo: times[maxIndexEnd])
    }
}