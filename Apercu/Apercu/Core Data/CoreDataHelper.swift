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
                newWorkout.setValue(text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: "desc")
                
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
                newWorkout.setValue(title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: "title")
                
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
    
    func updateCategory(startDate: NSDate, endDate: NSDate, categoryId: NSNumber) {
        let fetchRequest = NSFetchRequest(entityName: "Workout")
        fetchRequest.predicate = NSPredicate(format: "start = %@", startDate)
        
        do {
            let fetchedResult = try context.executeFetchRequest(fetchRequest)
            
            if fetchedResult.count != 0 {
                let workoutToUpdate = fetchedResult.first as? Workout
                
                workoutToUpdate?.category = categoryId
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
                newWorkout.setValue(categoryId, forKey: "category")
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
    
    func updateCategoryDescription(identifier: NSNumber, desc: String) {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", identifier)
        
        do {
            let fetchedResult = try context.executeFetchRequest(fetchRequest)
            
            if fetchedResult.count != 0 {
                let categoryToUpdate = fetchedResult.first as? Category
                
                let trimmedString = desc.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                categoryToUpdate?.title = trimmedString
                do {
                    try context.save()
                    CategoriesSingleton.sharedInstance.updateCategoryInfo()
                } catch {
                    print("Unable to save category!")
                }
            }
        } catch {
            print("Unable to find category")
        }
    }
    
    func updateCategoryColor(identifier: NSNumber, color: UIColor) {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", identifier)
        
        do {
            let fetchedResult = try context.executeFetchRequest(fetchRequest)
            
            if fetchedResult.count != 0 {
                let categoryToUpdate = fetchedResult.first as? Category
                
                categoryToUpdate?.color = color
                do {
                    try context.save()
                    CategoriesSingleton.sharedInstance.updateCategoryInfo()
                } catch {
                    print("Unable to save category!")
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
    
    func addNewCategory(color: UIColor) {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let fetchedCategories = try context.executeFetchRequest(fetchRequest) as! [Category]
            let newIndex = (fetchedCategories.first?.identifier?.integerValue)! + 1
            
            let newCategory = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: context) as! Category
            newCategory.identifier = newIndex
            newCategory.title = "New Category"
            newCategory.color = color
            
            do {
                try context.save()
            } catch {
                NSLog("Error saving new category")
            }
        } catch {
            NSLog("Error loading categories")
        }
    }
    
    func removeCategory(identifier: NSNumber) {
        if identifier == 0 {
            return
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicate = NSPredicate(format: "identifier == %@", identifier)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        do {
            let fetchedCategory = try context.executeFetchRequest(fetchRequest) as! [Category]
            
            context.deleteObject(fetchedCategory.first!)
            
            do {
                try context.save()
            } catch {
                NSLog("Error removing category")
            }
        } catch {
            
        }
        
        
        let workoutFetchRequest = NSFetchRequest(entityName: "Workout")
        let workoutPredicate = NSPredicate(format: "caregory == %@", identifier)
        workoutFetchRequest.predicate = workoutPredicate
        
        do {
            let fetchedWorkouts = try context.executeFetchRequest(workoutFetchRequest) as! [Workout]
            
            for workout in fetchedWorkouts {
                workout.category = nil
            }
            
            do {
                try context.save()
            } catch {
                
            }
        } catch {
            
        }
        
    }
}

