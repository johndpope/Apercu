//
// Created by David Lantrip on 1/31/16.
// Copyright (c) 2016 Apercu. All rights reserved.
//

import Foundation

class WorkoutFilter {

    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    var categoryFilter = [NSNumber]()
    var manualFilter = [NSDate]()
    var filterType: FilteredTableViewController.FilterType!
    var categoryBlackList = [NSDate]()

    init() {
        if defs?.objectForKey("selectedCategories") != nil {
            categoryFilter = defs?.objectForKey("selectedCategories") as! [NSNumber]
        }
        
        if defs?.objectForKey("selectedManual") != nil {
            manualFilter = defs?.objectForKey("selectedManual") as! [NSDate]
        }
        
        if defs?.objectForKey("categoryBlacklist") != nil {
            categoryBlackList = defs?.objectForKey("categoryBlacklist") as! [NSDate]
        }
    }
    
    func includeWorkout(date: NSDate, category: NSNumber?) -> Bool {
        if filterType == .Color {
            if (category == nil && categoryFilter.contains(0)) || (category != nil && categoryFilter.contains(category!)) {
                if !categoryBlackList.contains(date) {
                    return true
                }
            }
            return false
        } else {
            return manualFilter.contains(date)
        }
    }

}
