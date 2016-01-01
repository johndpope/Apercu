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
            var combinedWorkouts: [ApercuWorkout] = [ApercuWorkout]()
            
            if workoutResults != nil {
                
                let coreDataWorkouts: [Workout]? = self.getAllCoreDataWorkouts()
                var coreDataIndex = 0
                
                if coreDataWorkouts == nil || coreDataWorkouts?.count == 0 {
                    // Add all HKWorkouts if Core Data is empty or nil
                    for healthKitWorkout in workoutResults! {
                        combinedWorkouts.append(ApercuWorkout(healthKitWorkout: healthKitWorkout as? HKWorkout, workout: nil))
                    }
                    
                } else {
                    for var i = 0; i < workoutResults!.count; ++i {
                        
                        let healthKitStartDate = workoutResults![i].startDate
                        
                        // Add in any core data occuring before first HKWorkout
                        if coreDataWorkouts?.count > 0 {
                            while coreDataIndex < coreDataWorkouts?.count && coreDataWorkouts![coreDataIndex].start! < healthKitStartDate {
                                combinedWorkouts.append(ApercuWorkout(healthKitWorkout: nil, workout: coreDataWorkouts![coreDataIndex]))
                                ++coreDataIndex
                            }
                        }
                        
                        // Check if two dates are equal and add them, if not add the HKWorkout and continue
                        if coreDataIndex < coreDataWorkouts?.count {
                            if coreDataWorkouts![coreDataIndex].start?.isEqualToDate(healthKitStartDate) == true {
                                combinedWorkouts.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: coreDataWorkouts![coreDataIndex]))
                                ++coreDataIndex
                            } else {
                                combinedWorkouts.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: nil))
                            }
                        } else {
                            combinedWorkouts.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: nil))
                        }
                        
                        // On last i value for HKWorkouts check for remaning Core Data workouts and add them
                        if i == ((workoutResults?.count)! - 1) {
                            while coreDataIndex < coreDataWorkouts?.count {
                                combinedWorkouts.append(ApercuWorkout(healthKitWorkout: nil, workout: coreDataWorkouts![coreDataIndex]))
                                ++coreDataIndex
                            }
                        }
                        
                    }
                    
                }
                
            } else {
                // If no HKWorkouts add all Core Data workouts
                let coreDataWorkouts: [Workout]? = self.getAllCoreDataWorkouts()
                
                for coreDataWorkout in coreDataWorkouts! {
                    combinedWorkouts.append(ApercuWorkout(healthKitWorkout: nil, workout: coreDataWorkout))
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if workoutResults != nil {
                    completion(result: combinedWorkouts)
                } else {
                    completion(result: nil)
                }
            })
        }
        
        if healthStore != nil {
            healthStore.executeQuery(workoutQuery);
        }
    }
    
    func getCategoryFilteredWorkouts(categoryIdentifiers: [NSNumber]?, completion: (result: [ApercuWorkout]?) -> Void) {
        if healthStore == nil { setupHealthStore() }
        let predicate = HKQuery.predicateForSamplesWithStartDate(nil, endDate: nil, options: .None)
        
        let workoutQuery = HKSampleQuery.init(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: [descendingSort]) { (query, workoutResults, error) -> Void in
            var combinedWorkouts: [ApercuWorkout] = [ApercuWorkout]()
            
            if workoutResults != nil {
                
                let coreDataWorkouts: [Workout]? = self.getAllCoreDataWorkouts()
                var coreDataIndex = 0
                
                if coreDataWorkouts == nil || coreDataWorkouts?.count == 0 {
                    
                    for healthKitWorkout in workoutResults! {
                        combinedWorkouts.append(ApercuWorkout(healthKitWorkout: healthKitWorkout as? HKWorkout, workout: nil))
                    }
                    
                } else {
                    for var i = 0; i < workoutResults?.count; ++i {
                        
                        let healthKitStartDate = workoutResults![i].startDate
                        
                        if coreDataWorkouts?.count > 0 {
                            while coreDataIndex < coreDataWorkouts?.count && coreDataWorkouts![coreDataIndex].start! < healthKitStartDate {
                                let currentCoreDataWorkout = coreDataWorkouts![coreDataIndex];
                                let currentCategoryIdentifier = currentCoreDataWorkout.category
                                
                                if (currentCategoryIdentifier == nil && categoryIdentifiers?.contains(0) == true) || (currentCategoryIdentifier != nil && categoryIdentifiers?.contains(currentCategoryIdentifier!) == true) {
                                    combinedWorkouts.append(ApercuWorkout(healthKitWorkout: nil, workout: currentCoreDataWorkout))
                                }
                            }
                        }
                        
                        if coreDataIndex < coreDataWorkouts?.count {
                            if coreDataWorkouts![coreDataIndex].start?.isEqualToDate(healthKitStartDate) == true {
                                
                                if (coreDataWorkouts![coreDataIndex].category == nil && categoryIdentifiers?.contains(0) == true) || (coreDataWorkouts![coreDataIndex].category != nil && categoryIdentifiers?.contains(coreDataWorkouts![coreDataIndex].category!) == true) {
                                    
                                    combinedWorkouts.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: coreDataWorkouts![coreDataIndex]))
                                    
                                }
                            } else {
                                if coreDataWorkouts![coreDataIndex].category == nil && categoryIdentifiers?.contains(0) == true {
                                    combinedWorkouts.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: nil))
                                }
                            }
                        } else {
                            if categoryIdentifiers?.contains(0) == true {
                                combinedWorkouts.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: nil))
                            }
                        }
                        
                        
                        if i == ((workoutResults?.count)! - 1) {
                            while coreDataIndex < coreDataWorkouts?.count {
                                if  (coreDataWorkouts![coreDataIndex].category == nil && categoryIdentifiers?.contains(0) == true) || (coreDataWorkouts![coreDataIndex].category != nil && categoryIdentifiers?.contains(coreDataWorkouts![coreDataIndex].category!) == true) {
                                    
                                    combinedWorkouts.append(ApercuWorkout(healthKitWorkout: nil, workout: coreDataWorkouts![coreDataIndex]))
                                    ++coreDataIndex
                                    
                                }
                            }
                        }
                    }
                }
            } else {
                // No HKWorkouts Found
                let coreDataWorkouts: [Workout]? = self.getAllCoreDataWorkouts()
                
                for coreDataWorkout in coreDataWorkouts! {
                    if (coreDataWorkout.category == nil && categoryIdentifiers?.contains(0) == true) || (coreDataWorkout.category != nil && categoryIdentifiers?.contains(coreDataWorkout.category!) == true) {
                        
                        combinedWorkouts.append(ApercuWorkout(healthKitWorkout: nil, workout: coreDataWorkout))
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if workoutResults != nil {
                    completion(result: combinedWorkouts)
                } else {
                    completion(result: nil)
                }
            })
        }
        
        if healthStore != nil {
            healthStore.executeQuery(workoutQuery);
        }
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

