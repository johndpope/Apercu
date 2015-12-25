//
//  Template+CoreDataProperties.swift
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

extension Template {

    @NSManaged var desc: String?
    @NSManaged var title: String?
    @NSManaged var setData: NSObject?
    @NSManaged var supersetData: NSObject?
    @NSManaged var supersetGroups: NSObject?
    @NSManaged var tags: NSObject?

}
