//
//  File.swift
//  Apercu
//
//  Created by David Lantrip on 12/24/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class FilteredTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum FilterType: Int {
        case Color = 0
        case Manual = 1
    }
    
    @IBOutlet private var filterLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var filterSwitch: UISegmentedControl!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var tableViewHeight: NSLayoutConstraint!
    @IBOutlet private var button: UIButton!
    
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    let workoutDescription: WorkoutDescription = WorkoutDescription()
    var dateFormatter = NSDateFormatter()
    
    var workoutArray: [ApercuWorkout]!
    var filteredWorkoutsByColor = [ApercuWorkout]()
    var filteredWorkoutsManual = [ApercuWorkout]()
    var filteredWorkouts = [ApercuWorkout]()
    
    var isFirstLoad = true
    var filterType: FilterType!
    var index = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableViewHeight.constant = tableView.contentSize.height
        
//        button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        if defs?.integerForKey("filterType") == nil || defs?.integerForKey("filterType") == 0 {
            filterType = .Color
            filterSwitch.selectedSegmentIndex = 0
        } else {
            filterType = .Manual
            filterSwitch.selectedSegmentIndex = 1
        }
        updateButtonTitle()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        labelSetup()
        
        if self.tabBarController?.tabBar.hidden == true {
            self.tabBarController!.tabBar.hidden = false
        }
        // Get workouts based on filter stored in NSUserDefaults
//        filteredWorkouts = getFilteredWorkouts()
    }
    
    func getFilteredWorkouts() -> [ApercuWorkout] {
        if filterType == .Color {

        } else {
        
        }
        return [ApercuWorkout]()
    }
    
    func labelSetup() {
        if filterType == FilterType.Color {
            // Add else if for total count of filters to show "All Colors"
            var labelString: String!
            if filteredWorkoutsByColor.count == 0 {
                labelString = "Current Filter: None Selected"
            } else if filteredWorkoutsByColor.count == 1 {
                labelString = "Current Filter: 1 Type"
            } else {
                labelString = String(format: "Current Filter: %lu Types", filteredWorkoutsByColor.count)
            }
            filterLabel.text = labelString
        } else {
            let labelString = String(format: "Workouts Selected: %lu", filteredWorkoutsManual.count)
            filterLabel.text = labelString
        }
        
    }
    
    @IBAction func filterSwitchChanged(sender: AnyObject) {
        if filterSwitch.selectedSegmentIndex == 0 {
            filterType = .Color
            defs?.setInteger(filterType.rawValue, forKey: "filterType")
        } else {
            filterType = .Manual
            defs?.setInteger(filterType.rawValue, forKey: "filterType")
        }
        updateButtonTitle()
    }
    
    @IBAction func selectWorkouts(sender: AnyObject) {
        if filterType == .Color {
            performSegueWithIdentifier("toCategoryFilter", sender: self)
        } else {
            performSegueWithIdentifier("toManualSelection", sender: self)
        }
    }
    
    func updateButtonTitle() {
        if filterType == .Color {
            button.setTitle("Choose Categories", forState: .Normal)
//            button.titleLabel?.text = "Choose Categories"
        } else {
            button.setTitle("Select Workouts", forState: .Normal)
//           button.titleLabel?.text = "Select Workouts"
        }
        button.sizeToFit()
    }
    
    // MARK: - TableView Stuff
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        index = indexPath.row
//        performSegueWithIdentifier("toDetailView", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredWorkouts.count != 0 {
            return filteredWorkouts.count
        } else  {
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            if filterType == .Color {
                filteredWorkoutsByColor.removeAtIndex(indexPath.row)
            } else {
                filteredWorkoutsManual.removeAtIndex(indexPath.row)
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            labelSetup()
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CompareCell", forIndexPath: indexPath) as! CompareCell
        
        cell.layoutIfNeeded()
        cell.accessoryType = .None
        cell.colorView.hidden = true
        cell.mainLabel.text = ""
        cell.detailLabel.text = ""
        
        let row = indexPath.row
        
        if filteredWorkouts.count != 0 {
            cell.detailLabel.hidden = false
            
            let rowWorkout = filteredWorkouts[row]
            
            let dateString = dateFormatter.stringFromDate(rowWorkout.getStartDate()!)
            
            let detailBottom = workoutDescription.getWorkoutDescription(rowWorkout.healthKitWorkout!.workoutActivityType.rawValue)
            
            // if title show title not date
            cell.mainLabel.text = dateString
            cell.detailLabel.text = detailBottom
            
            let colorViewCenter = cell.colorView.center
            let newColorViewFrame = CGRectMake(cell.colorView.frame.origin.x, cell.colorView.frame.origin.y, 25, 25)
            cell.colorView.frame = newColorViewFrame
            cell.colorView.layer.cornerRadius = 12.5
            cell.colorView.center = colorViewCenter
            
        } else {
            cell.detailLabel.text = "";
            cell.colorView.hidden = true
            cell.accessoryType = .None
            cell.mainLabel.text = "No workouts found!"
            tableView.allowsSelection = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Remove"
    }
    
    // Mark: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "toCompareView" {
            if filteredWorkouts.count == 0 {
                let alert = UIAlertController(title: "Error", message: "No workouts to copmare.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        switch segue.identifier {
//            Need clases to cast as
//            case "toCategoryFilter": {
//                let destination = segue.destinationViewController as!
//            }
//        }
    }
}

