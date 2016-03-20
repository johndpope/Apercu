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
    var averageAttrs: [String: AnyObject]!
    var redAttrs: [String: AnyObject]!
    var greenAttrs: [String: AnyObject]!
    
    var headerAttributedStrings: [NSAttributedString]!
    let valueAttrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    
    let greenColor = UIColor(red: 148/255, green: 184/255, blue: 51/255, alpha: 1.0)
    let redColor = UIColor(red: 160/255, green: 40/255, blue: 40/255, alpha: 1)
    
    init() {
        headerStrings = ["Start Time:", "Duration:", "Moderate Activity:", "High Activity:", "High / Moderate Ratio:", "Distance:", "Calories:", "Activity Type:"]
        headerAttrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        
        headerAttributedStrings = [NSAttributedString]()
        
        for headerString in headerStrings {
            headerAttributedStrings.append(NSAttributedString(string: headerString, attributes: headerAttrs))
        }
        
        headerAttrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
        averageAttrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)]
        redAttrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), NSForegroundColorAttributeName: greenColor]
        greenAttrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline), NSForegroundColorAttributeName: redColor]
    }
    
    func allHeaderStrings() -> [NSAttributedString] {
        return headerAttributedStrings
    }
    
    func allValueStrings(values: [String: Double?]) -> [NSMutableAttributedString] {
        var valueStrings = [NSMutableAttributedString]()
        
        var dateString: String
        if let startTime = values["start"] {
            dateString = stringFromDate(NSDate(timeIntervalSince1970: startTime!))
        } else {
            dateString = "Not Specified"
        }
        valueStrings.append(NSMutableAttributedString(string: dateString, attributes: valueAttrs))
        
        var durationString: String
        if let duration = values["duration"]  {
            durationString = String(format: "%@ min", secondsToString(duration!))
        } else {
            durationString = "Not specified"
        }
        valueStrings.append(NSMutableAttributedString(string: durationString, attributes: valueAttrs))
        
        var moderateString: String
        if let moderateTime = values["moderate"] {
            if moderateTime != nil {
                moderateString = String(format: "%@ min", secondsToString(moderateTime!))
            } else {
                moderateString = "Not Specified"
            }
        } else {
            moderateString = "Not Specified"
        }
        valueStrings.append(NSMutableAttributedString(string: moderateString, attributes: valueAttrs))
        
        var highString: String
        var ratioString: String
        if let highTime = values["high"] {
            if highTime != nil {
                highString = String(format: "%@ min", secondsToString(highTime!))
                
                if highTime!  > 0 && values["moderate"] != nil {
                    ratioString = String(format: "%@", stringWithTwoDigits(values["high"]!! / values["moderate"]!!))
                } else {
                    ratioString = "N/A"
                }
            } else {
                highString = "Not Specified"
                ratioString = "N/A"
            }
        } else {    
            highString = "Not Specified"
            ratioString = "N/A"
        }
        valueStrings.append(NSMutableAttributedString(string: highString, attributes: valueAttrs))
        valueStrings.append(NSMutableAttributedString(string: ratioString, attributes: valueAttrs))
        
        var milesString: String
        if let miles = values["distance"]! {
            milesString = stringWithTwoDigits(miles)
        } else {
            milesString = "Not Specified"
        }
        valueStrings.append(NSMutableAttributedString(string: milesString, attributes: valueAttrs))
        
        var caloriesString: String
        if let calories = values["calories"]! {
            caloriesString = stringWithWholeNumber(calories)
        } else {
            caloriesString = "Not Specified"
        }
        valueStrings.append(NSMutableAttributedString(string: caloriesString, attributes: valueAttrs))
        
        var descriptionString: String
        if let description = values["desc"]! {
            descriptionString = String(format: "%@", WorkoutDescription().getWorkoutDescription(UInt(description))!)
        } else {
            descriptionString = "Not Specified"
        }
        valueStrings.append(NSMutableAttributedString(string: descriptionString, attributes: valueAttrs))
        
        return valueStrings
    }
    
    func applyColorAttributes(value: Double, diffString: String) -> NSMutableAttributedString {
        if value < 0 {
            let returnString = "+" + diffString
            return NSMutableAttributedString(string: returnString, attributes: redAttrs);
        } else {
            let returnString = "-" + diffString
            return NSMutableAttributedString(string: returnString, attributes: greenAttrs);
        }
    }
    
    func notApplicableString() -> NSMutableAttributedString {
        let returnString = "\nN/A"
        return NSMutableAttributedString(string: returnString, attributes: averageAttrs)
    }
    
    func attributedAverageString(averageString: String) -> NSMutableAttributedString {
        let returnString = String(format: "\nAvg: %@\n", averageString)
        return NSMutableAttributedString(string: returnString, attributes: averageAttrs)
    }
    
    func valueStringWithComparison(values: [String: Double?], averages: [String: Double?]) -> [NSAttributedString] {
        var workoutStrings = allValueStrings(values)

        if let averageDuration = averages["duration"] {
            let avgString = secondsToString(averageDuration!)
            workoutStrings[1].appendAttributedString(attributedAverageString(avgString))
            
            if let workoutDuration = values["duration"] {
                let rawValue = averageDuration! - workoutDuration!
                let value = fabs(averageDuration! - workoutDuration!)
                let diffString = secondsToString(value)
                workoutStrings[1].appendAttributedString(applyColorAttributes(rawValue, diffString: diffString))
            } else {
                workoutStrings[1].appendAttributedString(notApplicableString())
            }
        } else {
            workoutStrings[1].appendAttributedString(notApplicableString())
        }
        
        
        if let averageModerate = averages["moderate"] {
            let avgString = secondsToString(averageModerate!)
            workoutStrings[2].appendAttributedString(attributedAverageString(avgString))
            
            if let workoutModerateTime = values["moderate"] {
                if workoutModerateTime != nil && averageModerate != nil {
                let rawValue = averageModerate! - workoutModerateTime!
                let value = fabs(rawValue)
                let diffString = secondsToString(value)
                workoutStrings[2].appendAttributedString(applyColorAttributes(rawValue, diffString: diffString))
                } else {
                    workoutStrings[2].appendAttributedString(notApplicableString())
                }
            } else {
                workoutStrings[2].appendAttributedString(notApplicableString())
            }
        } else {
            workoutStrings[2].appendAttributedString(notApplicableString())
        }
        
        if let averageHigh = averages["high"] {
            let avgString = secondsToString(averageHigh!)
            workoutStrings[3].appendAttributedString(attributedAverageString(avgString))
            
            if let workoutHigh = values["high"] {
                if averageHigh != nil && workoutHigh != nil {
                let rawValue = averageHigh! - workoutHigh!
                let value = fabs(rawValue)
                let diffString = secondsToString(value)
                workoutStrings[3].appendAttributedString(applyColorAttributes(rawValue, diffString: diffString))
                } else {
                  workoutStrings[3].appendAttributedString(notApplicableString())  
                }
            } else {
                workoutStrings[3].appendAttributedString(notApplicableString())
            }
        }
        
        if let averageRatio = averages["ratio"] {
            let avgString = String(format: "%.2f", averageRatio!)
            workoutStrings[4].appendAttributedString(attributedAverageString(avgString))
            
            if values["high"]! != nil && values["moderate"]! != nil {
                let workoutRatio = values["high"]!! / values["moderate"]!!
                let rawValue = averageRatio! - workoutRatio
                let value = fabs(rawValue)

                let diffString = String(format: "%.2f", value)

                workoutStrings[4].appendAttributedString(applyColorAttributes(rawValue, diffString: diffString))
            } else {
                workoutStrings[4].appendAttributedString(notApplicableString())
            }
        } else {
            workoutStrings[4].appendAttributedString(notApplicableString())
        }
        
        if let averageDistance = averages["distance"] {
            let avgString = String(format: "%.2f", averageDistance!)
            workoutStrings[5].appendAttributedString(attributedAverageString(avgString))
            
            if let workoutDistance = values["distance"] {
                if workoutDistance != nil {
                    let rawValue = averageDistance! - workoutDistance!
                    let value = fabs(rawValue)
                    let diffString = String(format: "%.2f", value)
                    workoutStrings[5].appendAttributedString(applyColorAttributes(rawValue, diffString: diffString))
                } else {
                    workoutStrings[5].appendAttributedString(notApplicableString())
                }
            } else {
                workoutStrings[5].appendAttributedString(notApplicableString())
            }
        } else {
            workoutStrings[5].appendAttributedString(notApplicableString())
        }
        
        if let averageCalories = averages["calories"] {
            let avgString = String(format: "%.0f", averageCalories!)
            workoutStrings[6].appendAttributedString(attributedAverageString(avgString))
            
            if let workoutCalories = values["calories"] {
                if workoutCalories != nil {
                    let rawValue = averageCalories! - workoutCalories!
                    let value = fabs(rawValue)
                    let diffString = String(format: "%.0f", value)
                    workoutStrings[6].appendAttributedString(applyColorAttributes(rawValue, diffString: diffString))
                } else {
                    workoutStrings[6].appendAttributedString(notApplicableString())
                }
            } else {
                workoutStrings[6].appendAttributedString(notApplicableString())
            }
        } else {
            workoutStrings[6].appendAttributedString(notApplicableString())
        }
        
        return workoutStrings
    }
    
}