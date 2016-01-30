//
// Created by David Lantrip on 12/23/15.
// Copyright (c) 2015 Apercu. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

class WorkoutTableViewController: UITableViewController, UIViewControllerPreviewingDelegate {
    
    @IBOutlet weak private var workoutTableView: UITableView!
    @IBOutlet weak private var workoutButton: UIBarButtonItem!
    @IBOutlet var workoutRefreshControl: UIRefreshControl!
    
    var workoutArray: [ApercuWorkout]!
    var selectedWorkout: ApercuWorkout!
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    let dateFormatter = NSDateFormatter()
    
    var isFirstLoad = true
    var selectedIndex: Int!
    var appDelegate: AppDelegate!
    
    let categoriesSingleton = CategoriesSingleton.sharedInstance
    let workoutDescription = WorkoutDescription()
    
    let cellBackgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    //    let tabBackgroundColor = UIColor(red: 189.0/255.0, green: 189.0/255.0, blue: 193.0/255.0, alpha: 1.0)
    //    let tabBackgroundColor = UIColor(red: 167.0/255.0, green: 167.0/255.0, blue: 193.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        workoutTableView.estimatedRowHeight = 44.0
        workoutTableView.rowHeight = UITableViewAutomaticDimension
        
        if traitCollection.forceTouchCapability == UIForceTouchCapability.Available {
            registerForPreviewingWithDelegate(self, sourceView: view)
        }
        
        //        tabBarController!.tabBar.barTintColor = tabBaockgroundColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        HealthKitSetup().setupAuthorization { (didSucceed) -> Void in
            
            if !didSucceed {
                let alert = UIAlertController(title: "Error", message: "Unable to access HealthKit", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            
            self.loadWorkouts()
        }
        
        if self.tabBarController?.tabBar.hidden == true {
            self.tabBarController!.tabBar.hidden = false
        }
        
    }
    
    func loadWorkouts() {
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
            
            if self.workoutRefreshControl.refreshing {
                self.workoutRefreshControl.endRefreshing()
            }
            
            if self.appDelegate.quickAction == "com.apercu.apercu-most-recent" {
                self.selectedIndex = 0
                self.performSegueWithIdentifier("toDetailManual", sender: self)
                self.appDelegate.quickAction = nil
            }
        }
        
    }
    
    
    @IBAction func refresh(sender: UIKit.UIRefreshControl) {
        loadWorkouts()
        workoutRefreshControl.beginRefreshing()
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
            
            let colorViewCenter = cell.colorView.center
            let newColorViewFrame = CGRectMake(cell.colorView.frame.origin.x, cell.colorView.frame.origin.y, 25, 25)
            cell.colorView.frame = newColorViewFrame
            cell.colorView.layer.cornerRadius = 12.5
            cell.colorView.center = colorViewCenter
            
            if let color = categoriesSingleton.getColorForIdentifier(rowWorkout.workout?.category) {
                cell.colorView.backgroundColor = color
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
            
            if let categoryTitle = categoriesSingleton.getStringForIdentifier(rowWorkout.workout?.category) {
                detailString += categoryTitle
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
            
            
        } else {
            cell.detailLabel.text = "";
            cell.colorView.hidden = true
            cell.accessoryType = .None
            
            if isFirstLoad {
                cell.titleLabel.text = "Loading workouts!"
            } else {
                cell.titleLabel.text = "No workouts found!"
            }
            
            tableView.allowsSelection = false
        }
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.clearColor()
        } else {
            cell.backgroundColor = cellBackgroundColor
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        performSegueWithIdentifier("toDetailManual", sender: self)
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedIndex = indexPath.row
        return indexPath;
    }
    
    // Mark: - Segue & Transition
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailViewFromSingle" {
            let destinationVC = segue.destinationViewController as! WorkoutDetailViewController
            destinationVC.currentWorkout = workoutArray[selectedIndex]
            destinationVC.startDate = workoutArray[selectedIndex].getStartDate()
            destinationVC.healthKitWorkout = workoutArray[selectedIndex].healthKitWorkout
        } else {
            let destinationVC = segue.destinationViewController as! WorkoutDetailViewController
            destinationVC.currentWorkout = workoutArray[selectedIndex]
            destinationVC.startDate = workoutArray[selectedIndex].getStartDate()
            destinationVC.healthKitWorkout = workoutArray[selectedIndex].healthKitWorkout
        }
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let selectedCell = tableView.indexPathForRowAtPoint(location) {
            selectedIndex = selectedCell.row
            
            previewingContext.sourceRect = (tableView.cellForRowAtIndexPath(selectedCell)?.frame)!
            
            let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("DetailView") as! WorkoutDetailViewController
            destinationVC.currentWorkout = workoutArray[selectedIndex]
            destinationVC.startDate = workoutArray[selectedIndex].getStartDate()
            destinationVC.healthKitWorkout = workoutArray[selectedIndex].healthKitWorkout
            destinationVC.hidesBottomBarWhenPushed = true
//            hidesBottomBarWhenPushed = true
            return destinationVC
        } else {
            return nil
        }
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        navigationController?.showViewController(viewControllerToCommit, sender: self)
//        navigationController?.hidesBottomBarWhenPushed = true
        
//        showViewController(viewControllerToCommit, sender: self)
    }
    
}