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
    let descendingSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: true)
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    
    func getAllWorkouts(completion: (result: [ApercuWorkout]?) -> Void) {
        guard let healthStore = appDelegate.healthStore else {
            return
        }
        
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
                    for i in 0 ..< workoutResults!.count {
                        
                        let healthKitStartDate = workoutResults![i].startDate
                        
                        // Add in any core data occuring before first HKWorkout
                        if coreDataWorkouts?.count > 0 {
                            while coreDataIndex < coreDataWorkouts?.count && coreDataWorkouts![coreDataIndex].start! < healthKitStartDate {
                                combinedWorkouts.append(ApercuWorkout(healthKitWorkout: nil, workout: coreDataWorkouts![coreDataIndex]))
                                coreDataIndex += 1
                            }
                        }
                        
                        // Check if two dates are equal and add them, if not add the HKWorkout and continue
                        if coreDataIndex < coreDataWorkouts?.count {
                            if coreDataWorkouts![coreDataIndex].start?.isEqualToDate(healthKitStartDate) == true {
                                combinedWorkouts.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: coreDataWorkouts![coreDataIndex]))
                                coreDataIndex += 1
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
                                coreDataIndex += 1
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
                    completion(result: combinedWorkouts.reverse())
                } else {
                    completion(result: nil)
                }
            })
        }
        
        healthStore.executeQuery(workoutQuery);
    }
    
    func getFilteredWorkouts(filter: FilteredTableViewController.FilterType, completion: (filteredResult: [ApercuWorkout]?) -> Void) {
        
        var filteredWorkouts = [ApercuWorkout]()
        
        let workoutFilter = WorkoutFilter()
        workoutFilter.filterType = filter
        
        getAllWorkouts { (result) -> Void in
            if let allWorkouts = result {
                
                for workout in allWorkouts {
                    if workout.workout != nil {
                        if workoutFilter.includeWorkout(workout.getStartDate()!, category: workout.workout?.category) {
                            filteredWorkouts.append(workout)
                        }
                    } else {
                        if workoutFilter.includeWorkout(workout.getStartDate()!, category: nil) {
                            filteredWorkouts.append(workout)
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(filteredResult: filteredWorkouts)
                })
                
                
            }
        }
        
        
//        
//        guard let healthStore = appDelegate.healthStore else {
//            return
//        }
//        
//
//        
//        let predicate = HKQuery.predicateForSamplesWithStartDate(nil, endDate: nil, options: .None)
//        
//        let workoutQuery = HKSampleQuery.init(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: [descendingSort]) { (query, workoutResults, error) -> Void in
//            var combinedWorkouts: [ApercuWorkout] = [ApercuWorkout]()
//            
//            if workoutResults != nil {
//                
//                let coreDataWorkouts: [Workout]? = self.getAllCoreDataWorkouts()
//                var coreDataIndex = 0
//                
//                if coreDataWorkouts == nil || coreDataWorkouts?.count == 0 {
//                    
//                    for healthKitWorkout in workoutResults! {
//                        if workoutFilter.includeWorkout(healthKitWorkout.startDate, category: nil) {
//                            combinedWorkouts.append(ApercuWorkout(healthKitWorkout: healthKitWorkout as? HKWorkout, workout: nil))
//                        }
//                    }
//                    
//                } else {
//                    for var i = 0; i < workoutResults?.count; ++i {
//                        
//                        let healthKitStartDate = workoutResults![i].startDate
//                        
//                        if coreDataWorkouts?.count > 0 {
//                            while coreDataIndex < coreDataWorkouts?.count && coreDataWorkouts![coreDataIndex].start! < healthKitStartDate {
//                                let currentCoreDataWorkout = coreDataWorkouts![coreDataIndex];
//                                let currentCategoryIdentifier = currentCoreDataWorkout.category
//                                
//                                if workoutFilter.includeWorkout(currentCoreDataWorkout.start!, category: currentCategoryIdentifier) {
//                                    combinedWorkouts.append(ApercuWorkout(healthKitWorkout: nil, workout: currentCoreDataWorkout))
//                                }
//                            }
//                        }
//                        
//                        if coreDataIndex < coreDataWorkouts?.count {
//                            if coreDataWorkouts![coreDataIndex].start?.isEqualToDate(healthKitStartDate) == true {
//                                
//                                if workoutFilter.includeWorkout(coreDataWorkouts![coreDataIndex].start!, category: coreDataWorkouts![coreDataIndex].category) {
//                                    
//                                    combinedWorkouts.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: coreDataWorkouts![coreDataIndex]))
//                                    
//                                }
//                            } else {
//                                if workoutFilter.includeWorkout(coreDataWorkouts![coreDataIndex].start!, category: coreDataWorkouts![coreDataIndex].category) {
//                                    combinedWorkouts.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: nil))
//                                }
//                            }
//                        } else {
//                            if workoutFilter.includeWorkout(workoutResults![i].startDate, category: coreDataWorkouts![coreDataIndex].category) {
//                                combinedWorkouts.append(ApercuWorkout(healthKitWorkout: workoutResults![i] as? HKWorkout, workout: nil))
//                            }
//                        }
//                        
//                        
//                        if i == ((workoutResults?.count)! - 1) {
//                            while coreDataIndex < coreDataWorkouts?.count {
//                                if workoutFilter.includeWorkout(coreDataWorkouts![coreDataIndex].start!, category: coreDataWorkouts![coreDataIndex].category){
//                                    
//                                    combinedWorkouts.append(ApercuWorkout(healthKitWorkout: nil, workout: coreDataWorkouts![coreDataIndex]))
//                                    ++coreDataIndex
//                                    
//                                }
//                            }
//                        }
//                    }
//                }
//            } else {
//                // No HKWorkouts Found
//                let coreDataWorkouts: [Workout]? = self.getAllCoreDataWorkouts()
//                
//                for coreDataWorkout in coreDataWorkouts! {
//                    if workoutFilter.includeWorkout(coreDataWorkout.start!, category: coreDataWorkout.category){
//                        
//                        combinedWorkouts.append(ApercuWorkout(healthKitWorkout: nil, workout: coreDataWorkout))
//                    }
//                }
//            }
//
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                if workoutResults != nil {
//                    completion(result: combinedWorkouts)
//                } else {
//                    completion(result: nil)
//                }
//            })
//        }
//        
//        healthStore.executeQuery(workoutQuery);
    }
    
    
    func getAllCoreDataWorkouts() -> [Workout]? {
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Workout")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        
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

