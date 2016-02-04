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
    let categoriesSingleton = CategoriesSingleton.sharedInstance
    let workoutDescription = WorkoutDescription()
    let cellBackgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    
    var workoutArray: [ApercuWorkout]!
    var manualSelectionArray = [NSDate]()
    var categories = [Category]()
    var dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController!.tabBar.hidden = true
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        removeAllButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectAllButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        if defs?.objectForKey("selectedManual") != nil {
            manualSelectionArray = defs?.objectForKey("selectedManual") as! [NSDate]
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        categories = CoreDataHelper().getAllCategories()
        
        QueryHealthKitWorkouts().getAllWorkouts({ (result) -> Void in
            self.tableView.allowsSelection = true
            self.workoutArray = result
            self.tableView.reloadData()
        })
    }
    
    @IBAction func removeAllWorkouts(sender: UIButton) {
        manualSelectionArray.removeAll()
        storeSelectedManual()
        tableView.reloadData()
    }
    
    @IBAction func selectAllWorkouts(sender: UIButton) {
        manualSelectionArray.removeAll()
        for workout in workoutArray {
            manualSelectionArray.append(workout.getStartDate()!)
        }
        storeSelectedManual()
        tableView.reloadData()
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
            cell.accessoryType = .DisclosureIndicator
            
            let rowWorkout = workoutArray[indexPath.row]
            let startDate = rowWorkout.getStartDate()
            
            let colorViewCenter = cell.colorView.center
            let newColorViewFrame = CGRectMake(cell.colorView.frame.origin.x, cell.colorView.frame.origin.y, 25, 25)
            cell.colorView.frame = newColorViewFrame
            cell.colorView.layer.cornerRadius = 12.5
            cell.colorView.center = colorViewCenter
            
            if let color = categoriesSingleton.getColorForIdentifier(rowWorkout.workout?.category) {
                if color == UIColor.clearColor() {
                    cell.colorView.hidden = true
                } else {
                    cell.colorView.backgroundColor = color
                }
            } else {
                cell.colorView.hidden = true
            }
            
            var titleString: String
            var detailString = ""
            
            if rowWorkout.workout?.title != nil {
                titleString = (rowWorkout.workout?.title)!
                detailString += dateFormatter.stringFromDate(startDate!)
                detailString += "\n"
            } else {
                titleString = dateFormatter.stringFromDate(startDate!)
            }
            
            detailString += secondsToString((rowWorkout.getEndDate()?.timeIntervalSinceDate(rowWorkout.getStartDate()!))!) + " min"
            detailString += "\n"
            
            if categoriesSingleton.getStringForIdentifier(rowWorkout.workout?.category) != "No Category Selected" {
                detailString += categoriesSingleton.getStringForIdentifier(rowWorkout.workout?.category)!
                detailString += "\n"
            } else {
                if let workoutTypeString = workoutDescription.getWorkoutDescription(rowWorkout.healthKitWorkout?.workoutActivityType.rawValue) {
                    detailString += workoutTypeString
                    detailString += "\n"
                }
            }

            cell.titleLabel.text = titleString
            
            cell.detailLabel.text = detailString.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            cell.detailLabel.textColor = UIColor.darkGrayColor()
            
            if manualSelectionArray.contains(rowWorkout.getStartDate()!) {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
        } else {
            cell.detailLabel.text = "";
            cell.colorView.hidden = true
            cell.accessoryType = .None
            cell.titleLabel.text = "No workouts found!"
            tableView.allowsSelection = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedWorkout = workoutArray[indexPath.row]
        
        if manualSelectionArray.contains(selectedWorkout.getStartDate()!) {
            let indexToRemove = manualSelectionArray.indexOf(selectedWorkout.getStartDate()!)
            manualSelectionArray.removeAtIndex(indexToRemove!)
        } else {
            manualSelectionArray.append(selectedWorkout.getStartDate()!)
        }
        storeSelectedManual()
        tableView.reloadData()
    }
    
    // MARK: - Store to Defaults
    
    func storeSelectedManual() {
        defs?.setObject(manualSelectionArray, forKey: "selectedManual")
    }
}