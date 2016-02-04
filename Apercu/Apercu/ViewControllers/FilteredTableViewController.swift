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

class FilteredTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate {
    
    enum FilterType: Int {
        case Color = 0
        case Manual = 1
    }
    
    @IBOutlet private var filterLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var filterSwitch: UISegmentedControl!
    @IBOutlet private var button: UIButton!
    
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    let workoutDescription: WorkoutDescription = WorkoutDescription()
    let categoriesSingleton = CategoriesSingleton.sharedInstance
    let cellBackgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    var dateFormatter = NSDateFormatter()
    var categoryDateBlackList = [NSDate]()
    
    var workoutArray: [ApercuWorkout]!
    var filteredWorkoutsByColor = [ApercuWorkout]()
    var filteredWorkoutsManual = [ApercuWorkout]()
    var filteredWorkouts = [ApercuWorkout]()
    
    var isLoadingWorkouts = false
    var filterType: FilterType!
    var selectedIndex = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        navigationController!.navigationBar.translucent = false
        
        if traitCollection.forceTouchCapability == UIForceTouchCapability.Available {
            registerForPreviewingWithDelegate(self, sourceView: self.tableView)
        }
        
        if defs?.integerForKey("filterType") == nil || defs?.integerForKey("filterType") == 0 {
            filterType = .Color
            filterSwitch.selectedSegmentIndex = 0
        } else {
            filterType = .Manual
            filterSwitch.selectedSegmentIndex = 1
        }
        updateButtonTitle()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        labelSetup()
        
        if self.tabBarController?.tabBar.hidden == true {
            self.tabBarController!.tabBar.hidden = false
        }
        
        if defs?.objectForKey("categoryBlacklist") != nil {
            categoryDateBlackList = defs?.objectForKey("categoryBlacklist") as! [NSDate]
        }
        
        // Get workouts based on filter stored in NSUserDefaults
        getFilteredWorkouts()
    }
    
    func getFilteredWorkouts() {
        isLoadingWorkouts = true
        QueryHealthKitWorkouts().getFilteredWorkouts(filterType) { (result) -> Void in
            if result != nil {
                self.filteredWorkouts = result!
            } else {
                self.filteredWorkouts = [ApercuWorkout]()
            }
            self.tableView.reloadData()
            self.isLoadingWorkouts = false
            self.labelSetup()
        }
    }
    
    func labelSetup() {
        if filterType == FilterType.Color {
            
            var selectedCategories = [NSNumber]()
            
            if defs?.objectForKey("selectedCategories") != nil {
                selectedCategories = defs?.objectForKey("selectedCategories") as! [NSNumber]
            }
            // Add else if for total count of filters to show "All Colors"
            var labelString: String!
            if selectedCategories.count == 0 {
                labelString = "Current Filter: None Selected"
            } else if selectedCategories.count == 1 {
                labelString = "Current Filter: 1 Type"
            } else {
                labelString = String(format: "Current Filter: %lu Types", selectedCategories.count)
            }
            filterLabel.text = labelString
        } else {
            let labelString = String(format: "Workouts Selected: %lu", filteredWorkouts.count)
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
        getFilteredWorkouts()
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
        selectedIndex = indexPath.row
        performSegueWithIdentifier("filterToSingleDetail", sender: self)
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
                categoryDateBlackList.append(filteredWorkouts[indexPath.row].getStartDate()!)
                defs?.setObject(categoryDateBlackList, forKey: "categoryBlacklist")
            } else {
                if ((defs?.valueForKey("selectedManual")) != nil) {
                    var filterDates = defs?.valueForKey("selectedManual") as! [NSDate]
                    
                    if let selectedIndex = filterDates.indexOf(filteredWorkouts[indexPath.row].getStartDate()!) {
                        filterDates.removeAtIndex(selectedIndex)
                    }
                    
                    defs?.setObject(filterDates, forKey: "selectedManual")
                }
            }
            filteredWorkouts.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            labelSetup()
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! WorkoutCell
        
        
        if filteredWorkouts.count != 0 {
            tableView.allowsSelection = true
            cell.colorView.hidden = false
            cell.accessoryType = .DisclosureIndicator
            
            let rowWorkout = filteredWorkouts[indexPath.row]
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
            cell.accessoryType = .None
        } else {
            cell.detailLabel.text = "";
            cell.colorView.hidden = true
            cell.accessoryType = .None
            if isLoadingWorkouts {
                cell.titleLabel.text = "Loading workouts.."
            } else {
                cell.titleLabel.text = "No workouts found!"
            }
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
                let alert = UIAlertController(title: "Error", message: "No workouts to compare.", preferredStyle: .Alert)
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
    
    // Mark: - Segue & Transition
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "filterToSingleDetail" || segue.identifier == "toDetailManual"     {
            let destinationVC = segue.destinationViewController as! WorkoutDetailViewController
            destinationVC.currentWorkout = filteredWorkouts[selectedIndex]
            destinationVC.startDate = filteredWorkouts[selectedIndex].getStartDate()
            destinationVC.healthKitWorkout = filteredWorkouts[selectedIndex].healthKitWorkout
        }
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let selectedCell = tableView.indexPathForRowAtPoint(location) {
            selectedIndex = selectedCell.row
            
            previewingContext.sourceRect = (tableView.cellForRowAtIndexPath(selectedCell)?.frame)!
            
            let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! WorkoutDetailViewController
            destinationVC.currentWorkout = filteredWorkouts[selectedIndex]
            destinationVC.startDate = filteredWorkouts[selectedIndex].getStartDate()
            destinationVC.healthKitWorkout = filteredWorkouts[selectedIndex].healthKitWorkout
            destinationVC.hidesBottomBarWhenPushed = true
            return destinationVC
        } else {
            return nil
        }
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        navigationController?.showViewController(viewControllerToCommit, sender: self)
    }
}

