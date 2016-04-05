//
//  CategoriesSingleton.swift
//  Apercu
//
//  Created by David Lantrip on 12/28/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CategoriesSingleton {
    static let sharedInstance = CategoriesSingleton()
    
    var categories: [Category];
    var colorDictionary = [NSNumber : UIColor]()
    var titleDictionary = [NSNumber : String]()
    
    private init() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true)]
        
        do {
            categories = try managedContext.executeFetchRequest(fetchRequest) as! [Category]
            
            colorDictionary.removeAll()
            titleDictionary.removeAll()
            
            for item in categories {
                colorDictionary[item.identifier!] = item.color as? UIColor
                titleDictionary[item.identifier!] = item.title
            }
            
            
        } catch {
            categories =  [Category]()
        }
    }
    
    func getColorForIdentifier(identifier: NSNumber?) -> UIColor? {
        if identifier == nil || identifier == 0 {
            return UIColor.clearColor()
        } else {
            if colorDictionary[identifier!] == nil {
                return UIColor.clearColor()
            } else {
                return colorDictionary[identifier!]!
            }
        }
    }
    
    func getStringForIdentifier(identifier: NSNumber?) -> String? {
        if identifier == nil || identifier == 0 {
            return "No Category Selected"
        } else {
            if titleDictionary[identifier!] == nil {
                return "No Category Selected"
            } else {
                return titleDictionary[identifier!]!
            }
        }
    }
    
    func updateCategoryInfo() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: true)]
        
        do {
            categories = try managedContext.executeFetchRequest(fetchRequest) as! [Category]
            
            colorDictionary.removeAll()
            for item in categories {
                colorDictionary[item.identifier!] = item.color as? UIColor
                titleDictionary[item.identifier!] = item.title
            }
            
        } catch {
            categories =  [Category]()
        }
    }
}