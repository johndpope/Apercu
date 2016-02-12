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
    
    func allValueStrings(values: [Double?]) -> [NSMutableAttributedString] {
        var valueStrings = [NSMutableAttributedString]()
        
        var dateString: String
        if let value0 = values[0] {
            dateString = stringFromDate(NSDate(timeIntervalSince1970: value0))
        } else {
            dateString = "Not Specified"
        }
        valueStrings.append(NSMutableAttributedString(string: dateString, attributes: valueAttrs))
        
        
        var durationString: String
        if let value1 = values[1]  {
            durationString = String(format: "%@ min", secondsToString(value1))
        } else {
            durationString = "Not specified"
        }
        valueStrings.append(NSMutableAttributedString(string: durationString, attributes: valueAttrs))
        
        
        var moderateString: String
        if let value2 = values[2] {
            moderateString = String(format: "%@ min", secondsToString(value2))
        } else {
            moderateString = "Not Specified"
        }
        valueStrings.append(NSMutableAttributedString(string: moderateString, attributes: valueAttrs))
        
        
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
        valueStrings.append(NSMutableAttributedString(string: highString, attributes: valueAttrs))
        valueStrings.append(NSMutableAttributedString(string: ratioString, attributes: valueAttrs))
        
        var milesString: String
        if let value4 = values[4] {
            milesString = stringWithTwoDigits(value4)
        } else {
            milesString = "Not Specified"
        }
        valueStrings.append(NSMutableAttributedString(string: milesString, attributes: valueAttrs))
        
        
        var caloriesString: String
        if let value5 = values[5] {
            caloriesString = stringWithWholeNumber(value5)
        } else {
            caloriesString = "Not Specified"
        }
        valueStrings.append(NSMutableAttributedString(string: caloriesString, attributes: valueAttrs))
        
        
        var descriptionString: String
        if let value6 = values[6] {
            descriptionString = String(format: "%@", WorkoutDescription().getWorkoutDescription(UInt(value6))!)
        } else {
            descriptionString = "Not Specified"
        }
        valueStrings.append(NSMutableAttributedString(string: descriptionString, attributes: valueAttrs))
        
        
        return valueStrings
    }
    
    func valueStringWithComparison(values: [Double?], averages: [Double?]) -> [NSAttributedString] {
        // values
        
        var workoutStrings = allValueStrings(values)
        
        var i = 0
        while i < averages.count {
            
            switch i {
            case 0:
                if averages[i] != nil {
                    let avgString = String(format: "\nAvg: %@", secondsToString(averages[i]!))
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                    
                    if values[i + 1] > averages[i] {
                        let diffString = String(format: " +%@", secondsToString(fabs(averages[i]! - values[i+1]!)))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: greenAttrs))
                    } else {
                        let diffString = String(format: " -%@", secondsToString(fabs(averages[i]! - values[i+1]!)))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: redAttrs))
                    }
                } else {
                    let avgString = "\nN/A"
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                }
            case 1:
                if averages[i] != nil {
                    let avgString = String(format: "\nAvg: %@", secondsToString(averages[i]!))
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                    
                    if values[i + 1] > averages[i] {
                        let diffString = String(format: " +%@",  secondsToString(fabs(averages[i]! - values[i+1]!)))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: greenAttrs))
                    } else {
                         let diffString = String(format: " -%@",  secondsToString(fabs(averages[i]! - values[i+1]!)))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: redAttrs))
                    }
                } else {
                    let avgString = "\nN/A"
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                }
            case 2:
                if averages[i] != nil {
                    let avgString = String(format: "\nAvg: %@", secondsToString(averages[i]!))
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                    
                    if values[i + 1] > averages[i] {
                        let diffString = String(format: " +%@",  secondsToString(fabs(averages[i]! - values[i+1]!)))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: greenAttrs))
                    } else {
                        let diffString = String(format: " -%@",  secondsToString(fabs(averages[i]! - values[i+1]!)))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: redAttrs))
                    }
                } else {
                    let avgString = "\nN/A"
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                }
            case 3:
                if averages[i] != nil {
                    let avgString = String(format: "\nAvg: %.2f", averages[i]!)
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                    
                    if values[i + 1] > averages[i] {
                        let diffString = String(format: " +%.2f", fabs(averages[i]! - values[i + 1]!))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: greenAttrs))
                    } else {
                        let diffString = String(format: " -%.2f", fabs(averages[i]! - values[i + 1]!))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: redAttrs))
                    }
                } else {
                    let avgString = "\nN/A"
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                }   
            case 4:
                if averages[i] != nil {
                    let avgString = String(format: "\nAvg: %.2f", averages[i]!)
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                    
                    if values[i + 1] > averages[i] {
                        let diffString = String(format: " +%.2f", fabs(averages[i]! - values[i + 1]!))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: greenAttrs))
                    } else {
                        let diffString = String(format: " -%.2f", fabs(averages[i]! - values[i + 1]!))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: redAttrs))
                    }
                } else {
                    let avgString = "\nN/A"
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                }
            case 5:
                if averages[i] != nil {
                    let avgString = String(format: "\nAvg: %.0f", averages[i]!)
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                    
                    if values[i + 1] > averages[i] {
                        let diffString = String(format: " +%.0f", fabs(averages[i]! - values[i + 1]!))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: greenAttrs))
                    } else {
                        let diffString = String(format: " -%.0f", fabs(averages[i]! - values[i + 1]!))
                        workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: diffString, attributes: redAttrs))
                    }
                } else {
                    let avgString = "\nN/A"
                    workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
                }
            default:
                break;
            }
            
            
            //            let avgString = String(format: "\nAvg: %f", averages[i]!)
            //            workoutStrings[i + 1].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: averageAttrs))
            //
            //
            i += 1
        }
        
        return workoutStrings
        
        //        for (index, string) in workoutStrings.enumerate() {
        //            let avgString = String(format: "\nAvg: %d", averages[index]!)
        //
        //            workoutStrings[index].appendAttributedString(NSMutableAttributedString(string: avgString, attributes: valueAttrs))
        //
        //        }
        
        //        for tableString in workoutStrings {
        //            
        //            let avg = String(format: "\nAvg: %d", values)
        //        }
        
    }
    
}