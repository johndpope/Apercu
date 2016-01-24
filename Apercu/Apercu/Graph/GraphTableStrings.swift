//
//  GraphTableStrings.swift
//  Apercu
//
//  Created by David Lantrip on 1/2/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import UIKit

class GraphTableStrings {
    
    var headerStrings: [String]!
    var headerAttrs: [String: UIFont]!
    var headerAttributedStrings: [NSAttributedString]!
    
    init() {
        headerStrings = ["Start Time:", "Duration:", "Moderate Activity:", "High Activity:", "High / Moderate Ratio:", "Distance:", "Calories:", "Activity Type:"]
        headerAttrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        
        headerAttributedStrings = [NSAttributedString]()
        
        for headerString in headerStrings {
            headerAttributedStrings.append(NSAttributedString(string: headerString, attributes: headerAttrs))
        }
    }
    
    func allHeaderStrings() -> [NSAttributedString] {
        return headerAttributedStrings
    }
    
    func allValueStrings(values: [Double?]) -> [NSAttributedString] {
        let valueAttrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        var valueStrings = [NSAttributedString]()
        
        var dateString: String
        if let value0 = values[0] {
            dateString = stringFromDate(NSDate(timeIntervalSince1970: value0))
        } else {
            dateString = "Not Specified"
        }
        valueStrings.append(NSAttributedString(string: dateString, attributes: valueAttrs))
        
        
        var durationString: String
        if let value1 = values[1]  {
            durationString = String(format: "%@ min", secondsToString(value1))
        } else {
            durationString = "Not specified"
        }
        valueStrings.append(NSAttributedString(string: durationString, attributes: valueAttrs))
    
        
        var moderateString: String
        if let value2 = values[2] {
            moderateString = String(format: "%@ min", secondsToString(value2))
        } else {
            moderateString = "Not Specified"
        }
        valueStrings.append(NSAttributedString(string: moderateString, attributes: valueAttrs))
        
        
        var highString: String
        var ratioString: String
        if let value3 = values[3] {
            highString = String(format: "%@ min", secondsToString(value3))
            
            if value3  > 0 && values[2] != nil {
                ratioString = String(format: "%@", stringWithTwoDigits(values[3]! / values[2]!))
            } else {
                ratioString = "N/A"
            }
            
        } else {
            highString = "Not Specified"
            ratioString = "N/A"
        }
        valueStrings.append(NSAttributedString(string: highString, attributes: valueAttrs))
        valueStrings.append(NSAttributedString(string: ratioString, attributes: valueAttrs))
        
        var milesString: String
        if let value4 = values[4] {
            milesString = stringWithTwoDigits(value4)
        } else {
            milesString = "Not Specified"
        }
        valueStrings.append(NSAttributedString(string: milesString, attributes: valueAttrs))
        
        
        var caloriesString: String
        if let value5 = values[5] {
            caloriesString = stringWithWholeNumber(value5)
        } else {
            caloriesString = "Not Specified"
        }
        valueStrings.append(NSAttributedString(string: caloriesString, attributes: valueAttrs))
        
        
        var descriptionString: String
        if let value6 = values[6] {
            descriptionString = String(format: "%@", WorkoutDescription().getWorkoutDescription(UInt(value6))!)
        } else {
            descriptionString = "Not Specified"
        }
        valueStrings.append(NSAttributedString(string: descriptionString, attributes: valueAttrs))
        
        
        return valueStrings
    }
    
}