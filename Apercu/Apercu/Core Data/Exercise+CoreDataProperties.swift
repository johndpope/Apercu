//
//  Exercise+CoreDataProperties.swift
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

extension Exercise {

    @NSManaged var cardio: NSNumber?
    @NSManaged var desc: String?
    @NSManaged var id: NSNumber?
    @NSManaged var intensity: NSNumber?
    @NSManaged var title: String?

}
