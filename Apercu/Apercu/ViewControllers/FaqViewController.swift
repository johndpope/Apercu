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
        let actionSheet = UIAlertController(title: "Confirm Reset", message: "Reset categories", preferredStyle: .ActionSheet)
        
        let removeAction = UIAlertAction(title: "Reset", style: .Destructive) { (action) in
            
        }
        
        let defaultAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionSheet.addAction(removeAction)
        actionSheet.addAction(defaultAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func removeWorkouts(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Confirm Reset", message: "Reset categories", preferredStyle: .ActionSheet)
        
        let removeAction = UIAlertAction(title: "Reset", style: .Destructive) { (action) in
            
        }
        
        let defaultAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionSheet.addAction(removeAction)
        actionSheet.addAction(defaultAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}