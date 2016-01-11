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
        
        while index < bpm.count {
            var currentTotal = bpm[index]
            let startTime = times[index]
            var subIndex = 1
            
            while (index + subIndex) < bpm.count && (times[index + subIndex] - startTime) < duration {
                currentTotal += bpm[index + subIndex]
                ++subIndex
            }
            --subIndex
            
            if currentTotal > currentMax {
                currentMax = currentTotal
                maxIndexStart = index
                maxIndexEnd = index + subIndex
            }
            
            ++index
        }
        
//        if maxIndexEnd == bpm.count {
//            --maxIndexEnd
//        }
        
        print(duration)
        print(times[maxIndexEnd] - times[maxIndexStart])
        completion(timeOne: times[maxIndexStart], timeTwo: times[maxIndexEnd])
    }
}