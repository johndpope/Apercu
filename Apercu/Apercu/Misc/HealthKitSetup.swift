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
    
    func setupAuthorization() -> Bool{
        var didSucceed  = false
        
        if HKHealthStore.isHealthDataAvailable() {
            let typesToRead = healthKitDataTypesToRead()
            let typesToShare = healthKitTypesToShare()
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let healthStore = appDelegate.healthStore
            
            healthStore.requestAuthorizationToShareTypes(typesToShare, readTypes: typesToRead, completion: { (success, error) -> Void in
                if success {
                    didSucceed = true
                    
//                    Update birthday
                    let birthday: NSDate? = try? healthStore.dateOfBirth()
                    
                    if birthday != nil {
                        let ageComponents = NSCalendar.currentCalendar().components(.Year, fromDate: birthday!, toDate: NSDate(), options: [])
                        let age = ageComponents.year
                        NSUserDefaults.standardUserDefaults().setInteger(age, forKey: "hkage")
                    } else {
                        NSUserDefaults.standardUserDefaults().setInteger(25, forKey: "hkage")
                    }
                    

                } else {
                    didSucceed = false
                    NSLog("Apercu unable to reach HealthKit")
                }
            })
            
        }
        
        return didSucceed
    }
    
    func healthKitDataTypesToRead() -> Set <HKObjectType> {
        let heartRateType: HKObjectType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        let workoutType: HKObjectType = HKObjectType.workoutType()
        
        let birthdayType: HKObjectType = HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!
        let biologicalSexType: HKObjectType = HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!
        let weightType: HKObjectType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!
        
        return Set([heartRateType, workoutType, birthdayType, biologicalSexType, weightType])
    }
    
    func healthKitTypesToShare() -> Set <HKSampleType> {
        let workoutType = HKSampleType.workoutType()
        
        return Set([workoutType])
    }
    
}
