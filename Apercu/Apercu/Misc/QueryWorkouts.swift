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
    
    func workoutForTime(startDate: NSDate, endDate: NSDate, completion: (result: Bool) -> Void) {
        guard let healthStore = appDelegate.healthStore else {
            return
        }
        print(startDate)
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let workoutQuery = HKSampleQuery.init(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors:[descendingSort]) { (query, workoutResults, error) -> Void in
            
            var foundWorkoutForDate = false
            
            if workoutResults != nil {
            
            for workout in workoutResults as! [HKWorkout] {
                if workout.startDate == startDate && workout.endDate == endDate {
                    foundWorkoutForDate = true
                }
            }
            }
            
            completion(result: foundWorkoutForDate)
        }
        
        healthStore.executeQuery(workoutQuery)
    }
    
    func deleteHealthKitWorkout(startDate: NSDate, endDate: NSDate, completion: (result: [HKWorkout]?) -> Void) {
        guard let healthStore = appDelegate.healthStore else {
            return
        }
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let workoutQuery = HKSampleQuery.init(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors:[descendingSort]) { (query, workoutResults, error) -> Void in
            
            if workoutResults != nil && workoutResults?.count > 0 {
                for workout in (workoutResults as? [HKWorkout])! {
                    healthStore.deleteObject(workout, withCompletion: { (success, error) in
                        
                    })
                }
            }
            
            completion(result: workoutResults as? [HKWorkout])
        }
        
        healthStore.executeQuery(workoutQuery)
    }
    
}

func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
}

func > (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
}

