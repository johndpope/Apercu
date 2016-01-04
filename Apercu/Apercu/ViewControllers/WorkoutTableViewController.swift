//
// Created by David Lantrip on 12/23/15.
// Copyright (c) 2015 Apercu. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

class WorkoutTableViewController: UITableViewController {
    
    @IBOutlet weak private var workoutTableView: UITableView!
    @IBOutlet weak private var workoutButton: UIBarButtonItem!
    
    var workoutArray: [ApercuWorkout]!
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    let dateFormatter = NSDateFormatter()
    
    var isFirstLoad = true
    var selectedIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        workoutTableView.estimatedRowHeight = 44.0
        workoutTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let didGetHealthKitAuthorization = HealthKitSetup().setupAuthorization { (didSucceed) -> Void in
            
            if !didSucceed {
                let alert = UIAlertController(title: "Error", message: "Unable to access HealthKit", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
        }
        
        QueryHealthKitWorkouts().getAllWorkouts { (result) -> Void in
            self.workoutArray = result
            self.tableView.allowsMultipleSelection = true
            self.tableView.reloadData()
            
            if self.isFirstLoad {
                self.tableView.setNeedsLayout()
                self.tableView.layoutIfNeeded()
                self.tableView.reloadData()
                self.isFirstLoad = false
            }
        }
    }
    
    
    @IBAction func refresh(sender: UIKit.UIRefreshControl) {
        
    }
    
    // MARK: - TableView Stuff
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if workoutArray == nil || workoutArray.count == 0 {
            return 1
        } else {
            return workoutArray.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! WorkoutCell
        cell.layoutIfNeeded()
        
        if workoutArray != nil && workoutArray.count != 0 {
            
            cell.colorView.hidden = false
            cell.accessoryType = .DisclosureIndicator
            
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        performSegueWithIdentifier("toDetailViewFromSingle", sender: self)
    }
    
    // Mark: - Segue & Transition
    
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailViewFromSingle" {
            let destinationVC = segue.destinationViewController as! WorkoutDetailViewController
            destinationVC.currentWorkout = workoutArray[selectedIndex]
        }
    }
    
    
}