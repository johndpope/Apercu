//
//  WorkoutSet+CoreDataProperties.swift
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

extension WorkoutSet {

    @NSManaged var calories: NSNumber?
    @NSManaged var circuit: NSNumber?
    @NSManaged var desc: String?
    @NSManaged var distance: NSNumber?
    @NSManaged var duration: NSNumber?
    @NSManaged var exerciseId: NSNumber?
    @NSManaged var setId: NSNumber?
    @NSManaged var toFailure: NSNumber?
    @NSManaged var weight: NSNumber?
    @NSManaged var workoutId: NSNumber?
    @NSManaged var reps: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var pace: NSNumber?

}
