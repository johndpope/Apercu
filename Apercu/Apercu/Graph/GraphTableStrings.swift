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
        headerStrings = ["Duration:", "Moderate Activity:", "High Activity:", "High / Moderate Ratio:", "Distance:", "Calories:", "Activity Type:"]
        headerAttrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        
        headerAttributedStrings = [NSAttributedString]()
        
        for headerString in headerStrings {
            headerAttributedStrings.append(NSAttributedString(string: headerString, attributes: headerAttrs))
        }
    }
    
    func allHeaderStrings() -> [NSAttributedString] {
        return headerAttributedStrings
    }
    
    func allValueStrings(values: [Double]) -> [NSAttributedString] {
        let valueAttrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        
        var valueStrings = [NSAttributedString]()
        
        let durationString = String(format: "%@ min", secondsToString(values[0]))
        let moderateString = String(format: "%@ min", secondsToString(values[1]))
        let highString = String(format: "%@ min", secondsToString(values[2]))
        
        
        valueStrings.append(NSAttributedString(string: durationString, attributes: valueAttrs))
        valueStrings.append(NSAttributedString(string: moderateString, attributes: valueAttrs))
        valueStrings.append(NSAttributedString(string: highString, attributes: valueAttrs))
        
        if values[2] > 0 {
            valueStrings.append(NSAttributedString(string: stringWithTwoDigits(values[2] / values[1]), attributes: valueAttrs))
        } else {
            valueStrings.append(NSAttributedString(string: "N/A", attributes: valueAttrs))
        }
        
        let milesString = stringWithTwoDigits(values[3])
        valueStrings.append(NSAttributedString(string: milesString, attributes: valueAttrs))
        
        let caloriesString = stringWithWholeNumber(values[4])
        valueStrings.append(NSAttributedString(string: caloriesString, attributes: valueAttrs))
        
        let descriptionValue = UInt(values[5])
        valueStrings.append(NSAttributedString(string: WorkoutDescription().geWorkoutDescription(descriptionValue), attributes: valueAttrs))
        
        
        return valueStrings
    }
    
}