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
import CoreData

class QueryHealthKitWorkouts {
    var healthStore: HealthKit.HKHealthStore!
    let sampleType = HKSampleType.workoutType()
    let descendingSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    func setupHealthStore() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        healthStore = appDelegate.healthStore
    }
    
    func getAllWorkouts(completion: (result: [ApercuWorkout]?) -> Void) {
        if healthStore == nil { setupHealthStore() }
        let predicate = HKQuery.predicateForSamplesWithStartDate(nil, endDate: nil, options: .None)
        
        let workoutQuery = HKSampleQuery.init(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors:[descendingSort]) { (query, workoutResults, error) -> Void in
            var combinedArray: [ApercuWorkout] = [ApercuWorkout]()
            
            if workoutResults != nil {
                
                let coreDataWorkouts: [Workout]? = self.getAllCoreDataWorkouts()
                var coreDataIndex = 0
                
                for var i = 0; i < workoutResults!.count; ++i {
                    
                    let healthKitStartDate = workoutResults![i].startDate
                    
                    if coreDataWorkouts != nil && coreDataWorkouts?.count > 0 {
                        while coreDataIndex < coreDataWorkouts?.count && coreDataWorkouts![coreDataIndex].start! < healthKitStartDate {
                            combinedArray.append(ApercuWorkout(healthKitWorkout: nil, workout: coreDataWorkouts![coreDataIndex]))
                            ++coreDataIndex
                        }
                    }
                    
                    if coreDataWorkouts != nil && coreDataIndex < coreDataWorkouts?.count {
                        if coreDataWorkouts![coreDataIndex].start?.isEqualToDate(healthKitStartDate) == true {
                            combinedArray.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: coreDataWorkouts![coreDataIndex]))
                            ++coreDataIndex
                        } else {
                            combinedArray.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: nil))
                        }
                    } else {
                        combinedArray.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: nil))
                    }
                    
                    if i == ((workoutResults?.count)! - 1) {
                        if coreDataWorkouts != nil {
                            while coreDataIndex < coreDataWorkouts?.count {
                                combinedArray.append(ApercuWorkout(healthKitWorkout: nil, workout: coreDataWorkouts![coreDataIndex]))
                                ++coreDataIndex
                            }
                        }
                    }
                    
                }
                
            } else {
                let coreDataWorkouts: [Workout]? = self.getAllCoreDataWorkouts()
                
                for coreDataWorkout in coreDataWorkouts! {
                     combinedArray.append(ApercuWorkout(healthKitWorkout: nil, workout: coreDataWorkout))
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if workoutResults != nil {
                    completion(result: combinedArray)
                } else {
                    completion(result: nil)
                }
            })
        }
        
        if healthStore != nil {
            healthStore.executeQuery(workoutQuery);
        }
    }
    
    func getCategoryFilteredWorkouts(colorIds: [Int]?, completion: (result: [HKSample]?, success: Bool) -> Void) {
        if healthStore == nil { setupHealthStore() }
        
        // Query core data for workout start times with selected color and return them
        
    }
    
    
    func getAllCoreDataWorkouts() -> [Workout]? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Workout")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start", ascending: false)]
        
        do {
            let workoutArray = try managedContext.executeFetchRequest(fetchRequest) as! [Workout]
            return workoutArray
        } catch {
            return nil
        }
    }
    
}

func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
}

func > (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
}

