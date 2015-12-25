//
//  Category+CoreDataProperties.swift
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

extension Category {

    @NSManaged var identifier: NSNumber?
    @NSManaged var color: NSObject?
    @NSManaged var title: String?

}
