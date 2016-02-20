//
//  ProcessArray.swift
//  Apercu
//
//  Created by David Lantrip on 2/6/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import HealthKit


class ProcessArray {
    var numberProcessed = 0;
    var totalWorkouts = 0;
    
    var durationArray = [Double]()
    var moderateArray = [Double]()
    var highArray = [Double]()
    var ratioArray = [Double]()
    var distanceArray = [Double]()
    var caloriesArray = [Double]()
    
    var averagedStats = [String: Double]()
    
    func processGroup(workouts: [ApercuWorkout], completion: (results: [String: Double?]!) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.totalWorkouts = workouts.count - 1
            
            // duration, moderate, high, high/mod ratio, distance, calories
            
            for workout in workouts {
                ProcessWorkout().heartRatePlotDate(workout.getStartDate()!, end: workout.getEndDate()!, includeRaw: false, statsCompleted: {_ in
                    
                    }, completion: { (results) -> Void in
                        self.numberProcessed += 1
                        
                        if let duration = results["duration"] as? Double {
                            if duration.isNormal {
                                self.durationArray.append(duration)
                            }
                        }
                        
                        if let moderateTime = results["mod"] as? Double {
                            if moderateTime.isNormal {
                                self.moderateArray.append(moderateTime)
                            }
                        }
                        
                        if let highTime = results["high"] as? Double {
                            if highTime.isNormal {
                                self.highArray.append(highTime)
                                
                                if let moderateTime = results["mod"] as? Double {
                                    if moderateTime.isNormal {
                                        self.ratioArray.append(highTime / moderateTime)
                                    }
                                }
                            }
                        }
                        
                        if let distance = workout.healthKitWorkout?.totalDistance?.doubleValueForUnit(HKUnit.mileUnit()) {
                            if distance.isNormal {
                                self.distanceArray.append(distance)
                            }   
                            
                        }
                        
                        if let calories = workout.healthKitWorkout?.totalEnergyBurned?.doubleValueForUnit(HKUnit.kilocalorieUnit()) {
                            if calories.isNormal {
                                self.caloriesArray.append(calories)
                            }
                        }
                        
                        if self.numberProcessed == self.totalWorkouts {
                            // return data
                            var returnValues = [String: Double?]()
                            
                            if !self.durationArray.isEmpty {
                                    returnValues["duration"] = self.averageArray(self.durationArray)
                            } else {
                                returnValues["duration"] = nil
                            }
                            
                            if !self.moderateArray.isEmpty {
                                returnValues["moderate"] = self.averageArray(self.moderateArray)
                            } else {
                                returnValues["moderate"] = nil
                            }
                            
                            if !self.highArray.isEmpty {
                                returnValues["high"] = self.averageArray(self.highArray)
                            } else {
                                returnValues["high"] = nil
                            }
                            
                            if !self.ratioArray.isEmpty {
                                returnValues["ratio"] = self.averageArray(self.ratioArray)
                            } else {
                                returnValues["ratio"] = nil
                            }
                            
                            if !self.distanceArray.isEmpty {
                                returnValues["distance"] = self.averageArray(self.distanceArray)
                            } else {
                                returnValues["distance"] = nil
                            }
                            if !self.caloriesArray.isEmpty {
                                returnValues["calories"] = self.averageArray(self.caloriesArray)
                            } else {
                                returnValues["calories"] = nil
                            }
                            
                            completion(results: returnValues)
                        }
                        
                })
            }
            
        })
    }
    
    func averageArray(input: [Double]) -> Double {
        return input.reduce(0){$0 + $1} / Double(input.count)
    }
    
}