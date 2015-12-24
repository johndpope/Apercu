//
// Created by David Lantrip on 12/23/15.
// Copyright (c) 2015 Apercu. All rights reserved.
//

import Foundation
import HealthKit
import UIKit
//import WorkoutCell

class WorkoutTableViewController: UIKit.UITableViewController {

    @IBOutlet weak private var workoutTableView: UIKit.UITableView!
    @IBOutlet weak private var workoutButton: UIKit.UIBarButtonItem!

    var workoutArray: [HKSample]!
    let defs = NSUserDefaults.standardUserDefaults()
    let dateFormatter = NSDateFormatter()
    
    var isFirstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle

        workoutTableView.estimatedRowHeight = 44.0
        workoutTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let didGetHealthKitAuthorization = HealthKitSetup().setupAuthorization()
        
        if !didGetHealthKitAuthorization {
            let alert = UIAlertController(title: "Error", message: "Unable to access HealthKit", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        QueryHealthKitWorkouts().getAllWorkouts { (result, success) -> Void in
            if success {
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
    }
    
    @IBAction func refresh(sender: UIKit.UIRefreshControl) {
        
    }

    // MARK: - TableView Delegates
    
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
        
        let row = indexPath.row
        
        if workoutArray != nil && workoutArray.count != 0 {

            cell.colorView.hidden = false
            cell.accessoryType = .DisclosureIndicator
            
            let rowWorkout = workoutArray[row] as! HKWorkout
            let startDate = rowWorkout.startDate
            let titleString = dateFormatter.stringFromDate(startDate)
            
            cell.titleLabel.text = titleString
            
            let colorViewCenter = cell.colorView.center
            let newColorViewFrame = CGRectMake(cell.colorView.frame.origin.x, cell.colorView.frame.origin.y, 25, 25)
            cell.colorView.frame = newColorViewFrame
            cell.colorView.layer.cornerRadius = 12.5
            cell.colorView.center = colorViewCenter
            
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