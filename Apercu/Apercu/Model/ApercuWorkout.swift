//
//  File.swift
//  Apercu
//
//  Created by David Lantrip on 12/25/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import HealthKit

class ApercuWorkout {
    
    var workout: Workout?
    var healthKitWorkout: HKWorkout?
    
    var bpmValues: [Double]?
    var times: [Double]?
    var deltaTimes: [Double]?
    
    init (healthKitWorkout: HKWorkout?, workout: Workout?) {
        self.healthKitWorkout = healthKitWorkout
        self.workout = workout
    }
    
    func getStartDate() -> NSDate? {
        if let healthKitStart = healthKitWorkout?.startDate {
            return healthKitStart
        }
        
        if let apercuStart = workout?.start {
            return apercuStart
        }
        
        return nil
    }
    
    func getEndDate() -> NSDate? {
        if let healthKitStart = healthKitWorkout?.endDate {
            return healthKitStart
        }
        
        if let apercuStart = workout?.end {
            return apercuStart
        }
        
        return nil
    }
    
    
    
}