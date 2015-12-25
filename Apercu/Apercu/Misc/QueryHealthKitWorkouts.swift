//
//  QueryHealthKitWorkouts.swift
//  Apercu
//
//  Created by David Lantrip on 12/24/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

class QueryHealthKitWorkouts {
    var healthStore: HealthKit.HKHealthStore!
    let sampleType = HKSampleType.workoutType()
    let descendingSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    func setupHealthStore() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        healthStore = appDelegate.healthStore
    }
    
    func getAllWorkouts(completion: (result: [HKSample]?, success: Bool) -> Void) {
        if healthStore == nil { setupHealthStore() }
        let predicate = HKQuery.predicateForSamplesWithStartDate(nil, endDate: nil, options: .None)
        
        let workoutQuery = HKSampleQuery.init(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors:[descendingSort]) { (query, workoutResults, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if workoutResults != nil {
                    completion(result: workoutResults, success: true)
                } else {
                    completion(result: nil, success: false)
                }
            })
        }
        
        if healthStore != nil {
            healthStore.executeQuery(workoutQuery);
        }
    }
    
    func getColorFilteredWorkouts(colorIds: [Int]?, completion: (result: [HKSample]?, success: Bool) -> Void) {
        if healthStore == nil { setupHealthStore() }
        
        // Query core data for workout start times with selected color and return them
        
    }
    
    
}