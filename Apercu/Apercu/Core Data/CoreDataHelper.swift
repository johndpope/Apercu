//
//  CoreDataHelper.swift
//  Apercu
//
//  Created by David Lantrip on 1/17/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataHelper {
    
    var context: NSManagedObjectContext!
    
    init() {
        let appDelegate = (UIApplication.sharedApplication()).delegate as! AppDelegate!
        context = appDelegate.managedObjectContext
    }
    
    func updateTextDescription(text: String, startDate: NSDate, endDate: NSDate) {
        let fetchRequest = NSFetchRequest(entityName: "Workout")
        fetchRequest.predicate = NSPredicate(format: "start = %@", startDate)
        
        do {
            let fetchedResult = try context.executeFetchRequest(fetchRequest)
            
            if fetchedResult.count != 0 {
                let workoutToUpdate = fetchedResult.first as? Workout
                
                workoutToUpdate?.desc = text
                do {
                  try context.save()
                } catch {
                    print("Unable to save workout!")
                }
            } else {
                let entity = NSEntityDescription.entityForName("Workout", inManagedObjectContext: context)
                let newWorkout = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
                newWorkout.setValue(startDate, forKey: "start")
                newWorkout.setValue(endDate, forKey: "end")
                newWorkout.setValue(text, forKey: "desc")
                
                do {
                    try context.save()
                } catch {
                    print("Unable to save new workout!")
                }
            }
        } catch {
            print("Unable to find workout!")
        }
    }
    
    func updateTitle(title: String, startDate: NSDate, endDate: NSDate) {
        let fetchRequest = NSFetchRequest(entityName: "Workout")
        fetchRequest.predicate = NSPredicate(format: "start = %@", startDate)
        
        do {
            let fetchedResult = try context.executeFetchRequest(fetchRequest)
            
            if fetchedResult.count != 0 {
                let workoutToUpdate = fetchedResult.first as? Workout
                
                workoutToUpdate?.title = title
                do {
                    try context.save()
                } catch {
                    print("Unable to save workout!")
                }
            } else {
                let entity = NSEntityDescription.entityForName("Workout", inManagedObjectContext: context)
                let newWorkout = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
                newWorkout.setValue(startDate, forKey: "start")
                newWorkout.setValue(endDate, forKey: "end")
                newWorkout.setValue(title, forKey: "title")
                
                do {
                    try context.save()
                } catch {
                    print("Unable to save new workout!")
                }
            }
        } catch {
            print("Unable to find workout!")
        }
    }

    func getCoreDataWorkout(start: NSDate) -> Workout? {
        let fetchRequest = NSFetchRequest(entityName: "Workout")
        fetchRequest.predicate = NSPredicate(format: "start = %@", start)
        
        do {
            let fetchResults = try context.executeFetchRequest(fetchRequest)
            return fetchResults.first as? Workout
        } catch {
            return nil
        }
    }
}

