//
//  CategoryLookup.swift
//  Apercu
//
//  Created by David Lantrip on 12/28/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CategoryLookup {
    
    func getAllCategories() -> [Category] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true)]
        
        do {
            let fetchedCategories = try managedContext.executeFetchRequest(fetchRequest) as! [Category]
            return fetchedCategories
        } catch {
            NSLog("Error loading categories")
            return [Category]()
        }
    }
    
}