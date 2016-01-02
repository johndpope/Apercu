//
//  IntensityThresholdSingleton.swift
//  Apercu
//
//  Created by David Lantrip on 1/1/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class IntensityThresholdSingleton {
    static let sharedInstance = IntensityThresholdSingleton()
    
    var highIntensityThreshold: Double!
    var moderateIntensityThreshold: Double!
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    
    private init() {
        updateHeartRateRanges()
    }
    
    func updateHeartRateRanges() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        guard let healthStore = appDelegate.healthStore else {
            return
        }
        var birthday: NSDate!
        var age: Double = 25.0
        
        do {
            let healthKitBirthday = try healthStore.dateOfBirth()
            
            if defs?.objectForKey("customAge") == nil || defs?.boolForKey("useCustomAge")  == false {
                birthday = healthKitBirthday
            } else {
                if defs?.objectForKey("customBirthday") != nil {
                    birthday = defs?.objectForKey("customBirthday") as! NSDate
                }
            }
            
            if birthday != nil {
                let ageComponents = NSCalendar.currentCalendar().components(.Year, fromDate: birthday, toDate: NSDate(), options: [])
                age = Double(ageComponents.year)
            }
            
        } catch {
            
        }
        
        highIntensityThreshold = (220 - age) * 0.7
        moderateIntensityThreshold = (220 - age) * 0.5
    }
    
}

