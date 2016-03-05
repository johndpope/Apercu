//
//  QuerySamples.swift
//  Apercu
//
//  Created by David Lantrip on 1/1/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

class QuerySamples {
    var healthStore: HKHealthStore!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let heartRateUnit = HKUnit(fromString: "count/min")

    func getSampleData(start: NSDate, end: NSDate, completion: (bpmValues: [Double]?, timeValues: [Double]?) -> Void) {
        guard let healthStore = appDelegate.healthStore else {
            return
        }
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(start, endDate: end, options: .None)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let sampleType: HKQuantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: [sort]) { (query, results, error) -> Void in
            
            var bpm = [Double]()
            var times = [Double]()
            
            guard let sampleArray: [HKSample] = results else {
                completion(bpmValues: nil, timeValues: nil)
                return
            }
            
            for sample in sampleArray as! [HKQuantitySample] {
                times.append(sample.startDate.timeIntervalSince1970)
                bpm.append(sample.quantity.doubleValueForUnit(self.heartRateUnit))
            }
            completion(bpmValues: bpm, timeValues: times)
        }
     
        healthStore.executeQuery(query)
    }
    
}


    
    
    