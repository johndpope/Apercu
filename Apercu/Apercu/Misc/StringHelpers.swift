//
//  StringHelpers.swift
//  Apercu
//
//  Created by David Lantrip on 1/7/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import UIKit

func secondsToString(time: Double) -> String {
    
    let min = time / 60;
    let seconds = time % 60;
    
    var stringOut: String!
    
    if seconds < 10 {
        stringOut = String(format: "%ld:0%ld", Int(min), Int(seconds))
    } else {
        stringOut = String(format: "%ld:%ld", Int(min), Int(seconds))
    }
    
    return stringOut
}

func stringWithTwoDigits(input: Double) -> String {
    let numberFormatter = NSNumberFormatter()
    numberFormatter.numberStyle = .DecimalStyle
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.roundingMode = .RoundHalfUp
    
    return numberFormatter.stringFromNumber(input)!
}

func stringWithWholeNumber(input: Double) -> String {
    let numberFormatter = NSNumberFormatter()
    numberFormatter.numberStyle = .DecimalStyle
    numberFormatter.maximumFractionDigits = 0
    numberFormatter.roundingMode = .RoundHalfUp
    
    return numberFormatter.stringFromNumber(input)!
}