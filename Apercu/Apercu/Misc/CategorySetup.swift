//
//  CategorySetup.swift
//  Apercu
//
//  Created by David Lantrip on 12/24/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CategorySetup {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var managedContext: NSManagedObjectContext!
    
    func initializeCategoryData() {
        
        managedContext = appDelegate.managedObjectContext

        if categoryTableIsEmpty() {
            let color0: UIColor = UIColor.clearColor()
            let color1: UIColor = UIColor(red: 0.0 / 255.0, green: 67.0 / 255.0, blue: 88.0 / 255.0, alpha: 1)
            let color2: UIColor = UIColor(red: 1.0 / 255.0, green: 139.0 / 255.0, blue: 166.0 / 255.0, alpha: 1)
            let color3: UIColor = UIColor(red: 0.0 / 255.0, green: 183.0 / 255.0, blue: 241.0 / 255.0, alpha: 1)
            let color4: UIColor = UIColor(red: 113.0 / 255.0, green: 214.0 / 255.0, blue: 190.0 / 255.0, alpha: 1)
            let color5: UIColor = UIColor(red: 20.0 / 255.0, green: 166.0 / 255.0, blue: 91.0 / 255.0, alpha: 1)
            let color6: UIColor = UIColor(red: 191.0 / 255.0, green: 255.0 / 255.0, blue: 0.0 / 255.0, alpha: 1)
            let color7: UIColor = UIColor(red: 255.0 / 255.0, green: 245.0 / 255.0, blue: 61.0 / 255.0, alpha: 1)
            let color8: UIColor = UIColor(red: 255.0 / 255.0, green: 184.0 / 255.0, blue: 0.0 / 255.0, alpha: 1)
            let color9: UIColor = UIColor(red: 253.0 / 255.0, green: 116.0 / 255.0, blue: 0.0 / 255.0, alpha: 1)
            let color10: UIColor = UIColor(red: 255.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1)
            let color11: UIColor = UIColor(red: 255.0 / 255.0, green: 20.0 / 255.0, blue: 135.0 / 255.0, alpha: 1)
            let color12: UIColor = UIColor(red: 255.0 / 255.0, green: 0.0 / 255.0, blue: 230.0 / 255.0, alpha: 1)
            let color13: UIColor = UIColor(red: 127.0 / 255.0, green: 0.0 / 255.0, blue: 230.0 / 255.0, alpha: 1)
            
            let string0 = "None"
            let string1 = "Running"
            let string2 = "Walking"
            let string3 = "Weightlifting"
            let string4 = "Interval Training"
            let string5 = "Cycling"
            let string6 = "Basketball"
            let string7 = "Soccer"
            let string8 = "Football"
            let string9 = "Tennis"
            let string10 = "Hiking"
            let string11 = "5K Run"
            let string12 = "10K Run"
            let string13 = "Half Marathon"
            
            let colorArray: [UIColor] = [color0, color1, color2, color3, color4, color5, color6, color7, color8, color9, color10, color11, color12, color13]
            
            let stringArray: [String] = [string0, string1, string2, string3, string4, string5, string6, string7, string8, string9, string10, string11, string12, string13]
            
            
            for i in 0 ..< colorArray.count {
                let newCategory = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: managedContext) as! Category
                
                newCategory.identifier = i
                newCategory.title = stringArray[i]
                newCategory.color = colorArray[i]
            }
            
            do {
                try self.managedContext.save()
            } catch {
                NSLog("Error saving categories")
            }
        }

    }
    
    func categoryTableIsEmpty() -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "identifier", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let categoryArray = try managedContext.executeFetchRequest(fetchRequest)
            
            if categoryArray.count == 0 {
                return true
            } else {
                return false
            }
        } catch {
            NSLog("Error checking category existence")
            return false
        }
    }

}
