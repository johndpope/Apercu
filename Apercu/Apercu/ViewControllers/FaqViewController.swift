//
//  FaqViewController.swift
//  Apercu
//
//  Created by David Lantrip on 3/25/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import UIKit

class FaqViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "FAQs"
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabBarCont = self.tabBarController {
            if tabBarCont.tabBar.hidden == false {
                tabBarCont.tabBar.hidden = true
            }
        }
    }
    
    
    @IBAction func resetCategories(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Confirm Category Reset", message: nil, preferredStyle: .ActionSheet)
        
        let removeAction = UIAlertAction(title: "Reset", style: .Destructive) { (action) in
            if CoreDataHelper().removeAllCategories() {
                let alertView = UIAlertController(title: "Data Reset", message: "Categories have been reset.", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertView, animated: true, completion: nil)
            } else {
                let alertView = UIAlertController(title: "Data Reset", message: "Unable to reset categories.", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertView, animated: true, completion: nil)
            }
        }
        
        let defaultAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionSheet.addAction(removeAction)
        actionSheet.addAction(defaultAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func removeWorkouts(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Confirm Reset", message: "Reset categories", preferredStyle: .ActionSheet)
        
        let removeAction = UIAlertAction(title: "Reset", style: .Destructive) { (action) in
            CoreDataHelper().deleteApercuWorkouts({ (success) in
                if success {
                    let alertView = UIAlertController(title: "Workouts Removed", message: "Workout data removed.", preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                } else {
                    let alertView = UIAlertController(title: "Data Reset", message: "Categories have been reset.", preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                }
            })
        }
        
        let defaultAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionSheet.addAction(removeAction)
        actionSheet.addAction(defaultAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}