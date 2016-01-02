//
//  GraphAxisNumberFormatter.swift
//  Apercu
//
//  Created by David Lantrip on 1/1/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation


class GraphAxisNumberFormatter: NSNumberFormatter {
    
    override func stringForObjectValue(obj: AnyObject) -> String? {
        
        let total = obj as! Int
        let minutes = total / 60
        let seconds = total % 60
        
        var label: String!
        if seconds > 9 {
            label = String(format: "%lu:%lu", minutes, seconds)
        } else {
            label = String(format: "%lu:0%lu", minutes, seconds)
        }
        return label
    }
    
}
