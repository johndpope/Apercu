//
//  ManualFilterViewController.swift
//  Apercu
//
//  Created by David Lantrip on 12/27/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class ManualFilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var removeAllButton: UIButton!
    @IBOutlet var selectAllButton: UIButton!
    
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    var workoutArray: [ApercuWorkout]!
    var manualSelectionArray = [ApercuWorkout]()
    var categories = [Category]()
    var dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController!.tabBar.hidden = true
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        removeAllButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectAllButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        categories = CategoryLookup().getAllCategories()
        
        QueryHealthKitWorkouts().getAllWorkouts({ (result) -> Void in
            self.tableView.allowsSelection = true
            self.workoutArray = result
            self.tableView.reloadData()
        })
    }
    
    @IBAction func removeAllWorkouts(sender: UIButton) {
        
    }
    
    @IBAction func selectAllWorkouts(sender: UIButton) {
        
    }
    
    // Mark: - TableView Stuff
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if workoutArray == nil || workoutArray.count == 0 {
            return 1
        } else {
            return workoutArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! WorkoutCell
        
        if workoutArray != nil && workoutArray.count != 0 {
            cell.colorView.hidden = false
            cell.accessoryType = .None
            
            let rowWorkout = workoutArray[indexPath.row]
            let startDate = rowWorkout.getStartDate()
            let titleString = dateFormatter.stringFromDate(startDate!)
            
            cell.titleLabel.text = titleString
            
            let colorViewCenter = cell.colorView.center
            let newColorViewFrame = CGRectMake(cell.colorView.frame.origin.x, cell.colorView.frame.origin.y, 25, 25)
            cell.colorView.frame = newColorViewFrame
            cell.colorView.layer.cornerRadius = 12.5
            cell.colorView.center = colorViewCenter
            
            if let color = CategoriesSingleton.sharedInstance.getColorForIdentifier(rowWorkout.workout?.category) {
                cell.colorView.backgroundColor = color
            } else {
                cell.colorView.hidden = true
            }
            
            cell.detailLabel.text = "Detail Text"
            
        } else {
            cell.detailLabel.text = "";
            cell.colorView.hidden = true
            cell.accessoryType = .None
            cell.titleLabel.text = "No workouts found!"
            tableView.allowsSelection = false
        }
        
        return cell
    }
}