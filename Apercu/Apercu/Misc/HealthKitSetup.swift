//
//  HealthKitSetup.swift
//  Apercu
//
//  Created by David Lantrip on 12/24/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import HealthKit
import UIKit


class HealthKitSetup {
    
    func setupAuthorization(completion: (didSucceed : Bool) -> Void) {
        if HKHealthStore.isHealthDataAvailable() {
            let typesToRead = healthKitDataTypesToRead()
            let typesToShare = healthKitTypesToShare()
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let healthStore = appDelegate.healthStore
            
            healthStore.requestAuthorizationToShareTypes(typesToShare, readTypes: typesToRead, completion: { (success, error) -> Void in
                if success {
                    let birthday: NSDate? = try? healthStore.dateOfBirth()
                    
                    if birthday != nil {
                        let ageComponents = NSCalendar.currentCalendar().components(.Year, fromDate: birthday!, toDate: NSDate(), options: [])
                        let age = ageComponents.year
                        NSUserDefaults.init(suiteName: "group.com.apercu.apercu")!.setInteger(age, forKey: "hkage")
                    } else {
                        NSUserDefaults.init(suiteName: "group.com.apercu.apercu")!.setInteger(25, forKey: "hkage")
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(didSucceed: true)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(didSucceed: false)
                        NSLog("Apercu unable to reach HealthKit")
                    })
                }
            })
            
        }
    }
    
    func healthKitDataTypesToRead() -> Set <HKObjectType> {
        let heartRateType: HKObjectType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        let workoutType: HKObjectType = HKObjectType.workoutType()
        
        let birthdayType: HKObjectType = HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!
        let biologicalSexType: HKObjectType = HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!
        let weightType: HKObjectType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!
        
        return Set([heartRateType, workoutType, birthdayType])
    }
    
    func healthKitTypesToShare() -> Set <HKSampleType> {
        let workoutType = HKSampleType.workoutType()
        
        return Set([workoutType])
    }
    
}
