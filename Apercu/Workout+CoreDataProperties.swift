//
//  Workout+CoreDataProperties.swift
//  
//
//  Created by David Lantrip on 12/25/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Workout {

    @NSManaged var desc: String?
    @NSManaged var title: String?
    @NSManaged var start: NSDate?
    @NSManaged var end: NSDate?
    @NSManaged var category: NSNumber?
    @NSManaged var exercises: NSObject?
    @NSManaged var sets: NSObject?
    @NSManaged var animateGraph: NSNumber?
    @NSManaged var useCurve: NSNumber?
    @NSManaged var showPoints: NSNumber?

}
