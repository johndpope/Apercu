//
//  ProcessWorkout.swift
//  Apercu
//
//  Created by David Lantrip on 1/2/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import Accelerate

class ProcessWorkout {
    
    func heartRatePlotDate(start: NSDate, end: NSDate, includeRaw: Bool, statsCompleted: (stats: [String: AnyObject]) -> Void, completion: (results: [String: AnyObject]!) -> Void) {
        QuerySamples().getSampleData(start, end: end) { (bpmValues, timeValues) -> Void in
            
            guard bpmValues != nil else {
                completion(results: nil)
                return
            }
            
            var maximum: Double = 0
            var minimum: Double = 0
            var average: Double = 0
            var secondsOfModerate: Double = 0
            var secondsOfHigh: Double = 0
            var secondsAboveModerate: Double = 0
            
            // Needed for some transforms
            var zero: Double = 0.0
            var one: Double = 1.0
            
            // Basic stats
            let length: vDSP_Length = vDSP_Length((bpmValues?.count)!)
            vDSP_maxvD(bpmValues!, 1, &maximum, length)
            vDSP_minvD(bpmValues!, 1, &minimum, length)
            vDSP_meanvD(bpmValues!, 1, &average, length)
            
            var timeSinceStart = [Double](count: (timeValues?.count)!, repeatedValue: 0.0)
            var negatedStart = -1.0 * (timeValues?.first!)!
            vDSP_vsaddD(timeValues!, 1, &negatedStart, &timeSinceStart, 1, length)
            let duration: Double = timeSinceStart.last!
            
            var statsDict: [String: AnyObject] = ["max": maximum, "min": minimum, "duration": duration, "avg": average]
            if includeRaw {
                statsDict["bpm"] = bpmValues!
                statsDict["time"] = timeSinceStart
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                statsCompleted(stats: statsDict)
            })
            
            var highIntensityThreshold = Double(IntensityThresholdSingleton.sharedInstance.highIntensityThreshold)
            var moderateIntensityThreshold = Double(IntensityThresholdSingleton.sharedInstance.moderateIntensityThreshold)
            
            // Sets delta time vector
            let timeVector1 = Array(timeValues![1..<(timeValues?.count)!])
            let timeVector2 = Array(timeValues![0..<((timeValues?.count)! - 1)])
            var deltaTime = [Double](count: timeVector1.count, repeatedValue: 0.0)
            vDSP_vsubD(timeVector2, 1, timeVector1, 1, &deltaTime, 1, vDSP_Length(timeVector1.count))
            
            // Prepare bpm vectors, initialize the combined, high and mod intensity vectors
            let bpmVector1 = Array(bpmValues![1..<(bpmValues?.count)!])
            let bpmVector2 = Array(bpmValues![0..<((bpmValues?.count)! - 1)])
            var combinedBpmVector = [Double](count: bpmVector1.count, repeatedValue: 0.0)
            var highIntensityVector = [Double](count: bpmVector1.count, repeatedValue: 0.0)
            var moderateIntensityVector = [Double](count: bpmVector1.count, repeatedValue: 0.0)
            
            // CombinedBpmVector is updated to maximum of the two vectors at i
            vDSP_vmaxD(bpmVector1, 1, bpmVector2, 1, &combinedBpmVector, 1, vDSP_Length(bpmVector1.count))
            
            // High intensity transforms
            vDSP_vthresD(combinedBpmVector, 1, &highIntensityThreshold, &highIntensityVector, 1, vDSP_Length(bpmVector1.count))
            vDSP_vlimD(highIntensityVector, 1, &one, &one, &highIntensityVector, 1, vDSP_Length(highIntensityVector.count))
            vDSP_vthresD(highIntensityVector, 1, &zero, &highIntensityVector, 1, vDSP_Length(highIntensityVector.count))
            vDSP_dotprD(highIntensityVector, 1, deltaTime, 1, &secondsOfHigh, vDSP_Length(highIntensityVector.count))
            
            
            // Moderate activity transforms
            vDSP_vthresD(combinedBpmVector, 1, &moderateIntensityThreshold, &moderateIntensityVector, 1, vDSP_Length(combinedBpmVector.count))
            vDSP_vlimD(moderateIntensityVector, 1, &one, &one, &moderateIntensityVector, 1, vDSP_Length(moderateIntensityVector.count))
            vDSP_vthresD(moderateIntensityVector, 1, &zero, &moderateIntensityVector, 1, vDSP_Length(moderateIntensityVector.count))
            vDSP_dotprD(moderateIntensityVector, 1, deltaTime, 1, &secondsAboveModerate, vDSP_Length(moderateIntensityVector.count))
            
            secondsOfModerate = secondsAboveModerate - secondsOfHigh
            
            var responseDict = [String: AnyObject]()
            
            responseDict["mod"] = secondsOfModerate
            responseDict["high"] = secondsOfHigh
            
            completion(results: responseDict)
        }
    }
    
}