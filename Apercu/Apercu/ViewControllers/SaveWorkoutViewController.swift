
//
//  SaveWorkout.swift
//  Apercu
//
//  Created by David Lantrip on 8/30/15.
//  Copyright © 2015 David Lantrip. All rights reserved.
//

import Foundation
import UIKit
import HealthKit
import CoreData

class SaveWorkout: UIViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate, PickedCategoryDelegate {
    
    // Add colorview delegate
    
    @IBOutlet var descriptionTextView: UITextView!
    
    @IBOutlet weak var bottomButtonViewSpacing: NSLayoutConstraint!
    @IBOutlet var distanceView: UIView!
    @IBOutlet var caloriesView: UIView!
    @IBOutlet var scrollViewBottomSpace: NSLayoutConstraint!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var textViewHeight: NSLayoutConstraint!
    @IBOutlet var typeSegment: UISegmentedControl!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var calorieTextField: UITextField!
    @IBOutlet var distanceTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var calorieStepper: UIStepper!
    @IBOutlet var distanceStepper: UIStepper!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var colorIcon: UIView!
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet var distanceBackground: UIView!
    @IBOutlet var dateBackground: UIView!
    @IBOutlet var backgroundCategory: UIView!
    @IBOutlet var backgroundNameAndDesc: UIView!
    //    var colorViewDelegate: ColorViewDelegate?
    
    let defs = NSUserDefaults(suiteName: "group.com.apercu.apercu")
    var toolbar: UIToolbar!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var managedContext: NSManagedObjectContext!
    var allTags: [String]!
    
    let bgColor = UIColor(red: 189/255, green: 212/255, blue: 222/255, alpha: 1)
    let globalTintColor = UIColor(red: 0/255, green: 125/255, blue: 164/255, alpha: 0.7)
    
    var selectedTags: [String]!
    var datePicker: UIDatePicker!
    var startDate: NSDate!
    var endDate: NSDate!
    var categoryColor: UIColor!
    let dateFormatter = NSDateFormatter()
    let dateFormatString = "hh:mm a MMM d yyyy"
    let categoriesSingleton = CategoriesSingleton.sharedInstance
    var selectedCategory: NSNumber?
    
    var calories = 0.0
    var distance = 0.0
    
    var isShowingWorkoutView = true
    @IBOutlet var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet var caloriesBottomConstraint: NSLayoutConstraint!
    @IBOutlet var startDateTopConstraint: NSLayoutConstraint!
    @IBOutlet var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tagsLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var startDateTextField: UITextField!
    @IBOutlet var endDateTextField: UITextField!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Workout"
        
        let radius: CGFloat = 4.0
        backgroundNameAndDesc.layer.cornerRadius = radius
        backgroundCategory.layer.cornerRadius = radius
        distanceBackground.layer.cornerRadius = radius
        dateBackground.layer.cornerRadius = radius
        
        setBorder(backgroundNameAndDesc)
        setBorder(backgroundCategory)
        setBorder(distanceBackground)
        setBorder(dateBackground)
        
        tabBarController!.tabBar.hidden = true
        
        managedContext = appDelegate.managedObjectContext
        calorieTextField.delegate = self
        distanceTextField.delegate = self
        nameTextField.delegate = self
        endDateTextField.delegate = self
        startDateTextField.delegate = self
        descriptionTextView.delegate = self
        
        startDateLabel.adjustsFontSizeToFitWidth = true
        endDateLabel.adjustsFontSizeToFitWidth = true
        
        let fixedWidth = descriptionTextView.frame.size.width
        descriptionTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = descriptionTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = descriptionTextView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        //        descriptionTextView.frame = newFrame;
        textViewHeight.constant = newFrame.size.height
        descriptionTextView.layer.cornerRadius = 6.0
        colorIcon.layer.cornerRadius = 12.5
        
        colorIcon.layer.borderColor = UIColor.whiteColor().CGColor
        colorIcon.layer.borderWidth = 1.0
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        datePicker.minuteInterval = 1
        datePicker.backgroundColor = UIColor.whiteColor()
        startDateTextField.inputView = datePicker
        endDateTextField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(SaveWorkout.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        selectedTags = [String]()
        
        collectionView.delegate = self
        
        if defs?.objectForKey("templateTags") != nil {
            allTags = defs?.objectForKey("templateTags") as! [String]
        } else {
            allTags = [String]()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SaveWorkout.showKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SaveWorkout.hideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        if typeSegment.selectedSegmentIndex == 0 {
            showWorkoutViews()
        } else {
            showTemplateViews()
        }
        
        
//        dateFormatter.dateFormat = dateFormatString
//        startDateTextField.text = dateFormatter.stringFromDate(NSDate().dateByAddingTimeInterval(-3600))
//        startDate = NSDate().dateByAddingTimeInterval(-3600)
//        endDateTextField.text = dateFormatter.stringFromDate(NSDate())
//        endDate = NSDate()
//        updateDurationLabel()
        
        collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize().height
        
        if((defs?.objectForKey("currentWorkout")) != nil) {
            let currentWorkout = defs?.objectForKey("currentWorkout") as! [[String: Double]]
            
            for exerciseSet in currentWorkout {
                if let setCalories = exerciseSet["calories"] {
                    calories += setCalories
                }
                
                if let setDistance = exerciseSet["distance"] {
                    distance += setDistance
                }
            }
        }
        
        distanceStepper.value = distance
        calorieStepper.value = calories
        
        distanceTextField.text = String(format: "%g", distance)
        calorieTextField.text = String(format: "%g", calories)
        //        collectionViewHeight.constant = collectionView.contentSize.height
    }
    
    func setBorder(view: UIView) {
        let fillColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        let borderColor = UIColor(red: 199/255, green: 205/255, blue: 221/255, alpha: 1.0)
        view.layer.borderWidth = 1.0
        view.layer.borderColor = borderColor.CGColor
        view.backgroundColor = fillColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabBarCont = self.tabBarController {
            if tabBarCont.tabBar.hidden == false {
                tabBarCont.tabBar.hidden = true
            }
        }
        
        dateFormatter.dateFormat = dateFormatString
        startDateTextField.text = dateFormatter.stringFromDate(NSDate().dateByAddingTimeInterval(-3600))
        startDate = NSDate().dateByAddingTimeInterval(-3600)
        endDateTextField.text = dateFormatter.stringFromDate(NSDate())
        endDate = NSDate()
        updateDurationLabel()
    }
    
    func showWorkoutViews() {
        UIView.performWithoutAnimation({ () -> Void in
            self.saveButton.setTitle("Save as Workout", forState: UIControlState.Normal)
            //            self.tagsLabelTopConstraint.active = false
            self.collectionViewBottomConstraint.active = false
            //            self.startDateTopConstraint.active = true
            //            self.caloriesBottomConstraint.active = true
            
            self.startDateTextField.hidden = false
            self.endDateTextField.hidden = false
            self.startDateLabel.hidden = false
            self.endDateLabel.hidden = false
            self.durationLabel.hidden = false
            self.caloriesView.hidden = false
            self.distanceView.hidden = false
            self.colorIcon.hidden = false
            self.categoryButton.hidden = false
            
            self.collectionView.hidden = true
            self.tagsLabel.hidden = true
        })
    }
    
    func showTemplateViews() {
        UIView.performWithoutAnimation({ () -> Void in
            self.saveButton.setTitle("Save as Template", forState: UIControlState.Normal)
            self.tagsLabelTopConstraint.active = true
            self.collectionViewBottomConstraint.active = true
            self.startDateTopConstraint.active = false
            self.caloriesBottomConstraint.active = false
            
            self.startDateTextField.hidden = true
            self.endDateTextField.hidden = true
            self.startDateLabel.hidden = true
            self.endDateLabel.hidden = true
            self.durationLabel.hidden = true
            self.caloriesView.hidden = true
            self.distanceView.hidden = true
            self.colorIcon.hidden = true
            self.categoryButton.hidden = true
            
            self.collectionView.hidden = false
            self.tagsLabel.hidden = false
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text != nil {
            let text: NSString = textField.text!
            
            if textField == nameTextField {
                
            } else if textField == calorieTextField {
                calorieStepper.value = text.doubleValue
            } else if textField == distanceTextField {
                distanceStepper.value = text.doubleValue
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        showToolbar()
        
        if textField == startDateTextField {
            datePicker.setDate(dateFormatter.dateFromString(startDateTextField.text!)!, animated: false)
        } else if (textField == endDateTextField) {
            datePicker.setDate(dateFormatter.dateFromString(endDateTextField.text!)!, animated: true)
        }
    }
    
    func showToolbar() {
        toolbar = UIToolbar()
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SaveWorkout.hideKeyboard as (SaveWorkout) -> () -> ()))
        let nextButton: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SaveWorkout.nextTextField))
        toolbar.setItems([nextButton, spacer, doneButton], animated: true)
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.whiteColor()
        toolbar.tintColor = UIColor.redColor()
        if nameTextField.isFirstResponder() {
            nameTextField.inputAccessoryView = toolbar
        } else if calorieTextField.isFirstResponder() {
            calorieTextField.inputAccessoryView = toolbar
        } else if distanceTextField.isFirstResponder() {
            distanceTextField.inputAccessoryView = toolbar
        } else if startDateTextField.isFirstResponder() {
            startDateTextField.inputAccessoryView = toolbar
        } else if endDateTextField.isFirstResponder() {
            endDateTextField.inputAccessoryView = toolbar
        }
    }
    
    func hideKeyboard() {
        if nameTextField.isFirstResponder() {
            nameTextField.endEditing(true)
            nameTextField.resignFirstResponder()
        } else if calorieTextField.isFirstResponder() {
            calorieTextField.endEditing(true)
            calorieTextField.resignFirstResponder()
        } else if distanceTextField.isFirstResponder() {
            distanceTextField.endEditing(true)
            distanceTextField.resignFirstResponder()
        } else if endDateTextField.isFirstResponder() {
            endDateTextField.endEditing(true)
            endDateTextField.resignFirstResponder()
        } else if startDateTextField.isFirstResponder() {
            startDateTextField.endEditing(true)
            startDateTextField.resignFirstResponder()
        } else if descriptionTextView.isFirstResponder() {
            descriptionTextView.endEditing(true)
            descriptionTextView.resignFirstResponder()
        }
        
        if toolbar != nil {
            toolbar.hidden = true
        }
    }
    
    
    func showKeyboard(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
                
                self.bottomButtonViewSpacing.constant = keyboardSize.height
                self.view.setNeedsUpdateConstraints()
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
                
                //                                bottomSpaceConstraint.constant = keyboardSize.height //- 44
            }
        }
    }
    
    func hideKeyboard(notification: NSNotification) {
        let contentInset = UIEdgeInsetsZero;
        scrollView.contentInset = contentInset
        bottomSpaceConstraint.constant = 0
        //        scrollViewBottomSpace.constant = 0
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.bottomButtonViewSpacing.constant = 0
        })
    }
    
    func nextTextField() {
        if nameTextField.isFirstResponder() {
            nameTextField.resignFirstResponder()
            descriptionTextView.becomeFirstResponder()
            scrollToTextView(scrollView.convertRect(descriptionTextView.frame, fromView: descriptionTextView))
        } else if descriptionTextView.isFirstResponder() {
            if isShowingWorkoutView {
                descriptionTextView.resignFirstResponder()
                startDateTextField.becomeFirstResponder()
                scrollToTextView(scrollView.convertRect(startDateTextField.frame, fromView: startDateTextField))
            } else {
                descriptionTextView.resignFirstResponder()
            }
            //            scrollToTextView(startDateTextField)
        } else if startDateTextField.isFirstResponder() {
            startDateTextField.resignFirstResponder()
            endDateTextField.becomeFirstResponder()
            scrollToTextView(scrollView.convertRect(endDateTextField.frame, fromView: endDateTextField))
        } else if endDateTextField.isFirstResponder() {
            endDateTextField.resignFirstResponder()
            distanceTextField.becomeFirstResponder()
            scrollToTextView(scrollView.convertRect(distanceTextField.frame, fromView: distanceTextField))
        } else if distanceTextField.isFirstResponder() {
            distanceTextField.resignFirstResponder()
            calorieTextField.becomeFirstResponder()
            scrollToTextView(scrollView.convertRect(calorieTextField.frame, fromView: calorieTextField))
        } else if calorieTextField.isFirstResponder() {
            calorieTextField.resignFirstResponder()
        }
    }
    
    func scrollToTextView(frame: CGRect) {
        print(frame)
        self.scrollView.scrollRectToVisible(frame, animated: true)
        //        UIView.animateWithDuration(NSTimeInterval(0.2), delay: 0.0, options: .TransitionNone, animations: {
        //        self.scrollView.contentOffset = CGPointMake(inputView.frame.origin.x + (inputView.superview?.frame.origin.x)!, inputView.frame.origin.y + (inputView.superview?.frame.origin.y)!)
        //            }) { (Bool) in
        //                    self.scrollView.contentOffset = CGPointMake(inputView.frame.origin.x, inputView.frame.origin.y)
        //        }
    }
    
    @IBAction func typeSegmentChanged(sender: AnyObject) {
        if typeSegment.selectedSegmentIndex == 0 {
            showWorkoutViews()
        } else {
            showTemplateViews()
            collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize().height
            //            collectionView.reloadData()
            //            collectionViewHeight.constant = collectionView.contentSize.height
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let text = NSString(string: allTags[indexPath.row])
        var size = text.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(17)])
        size.width += 25
        size.height += 25
        
        return size
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return allTags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagReuse", forIndexPath: indexPath) as! TagCell
        cell.tagLabel.text = allTags[indexPath.row]
        cell.tagLabel.font = UIFont.systemFontOfSize(17)
        cell.layer.cornerRadius = 6.0
        cell.backgroundColor = bgColor
        
        if selectedTags.contains(allTags[indexPath.row]) {
            cell.backgroundColor = globalTintColor
        }
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCell
        cell.backgroundColor = globalTintColor
        
        if !selectedTags.contains(cell.tagLabel.text!) {
            selectedTags.append(cell.tagLabel.text!)
        } else {
            if let indexOfTag = selectedTags.indexOf(cell.tagLabel.text!) {
                selectedTags.removeAtIndex(indexOfTag)
            }
        }
        
        collectionView.reloadData()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        toolbar = UIToolbar()
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SaveWorkout.hideKeyboard as (SaveWorkout) -> () -> ()))
        let nextButton: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SaveWorkout.nextTextField))
        toolbar.setItems([nextButton, spacer, doneButton], animated: true)
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.whiteColor()
        toolbar.tintColor = UIColor.redColor()
        descriptionTextView.inputAccessoryView = toolbar
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = descriptionTextView.frame.size.width
        descriptionTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = descriptionTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = descriptionTextView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        //        descriptionTextView.frame = newFrame;
        textViewHeight.constant = newFrame.size.height
    }
    
    func datePickerChanged(sender: UIDatePicker) {1
        if startDateTextField.isFirstResponder() {
            startDate = sender.date
            startDateTextField.text = dateFormatter.stringFromDate(sender.date)
        } else if endDateTextField.isFirstResponder() {
            endDate = sender.date
            endDateTextField.text = dateFormatter.stringFromDate(sender.date)
        }
        updateDurationLabel()
    }
    
    @IBAction func distanceStepperChanged(sender: AnyObject) {
        distance = distanceStepper.value
        distanceTextField.text = String(format: "%g", distance)
    }
    
    
    @IBAction func calorieStepperChanged(sender: AnyObject) {
        calories = calorieStepper.value
        calorieTextField.text = String(format: "%g", calories)
    }
    
    
    func updateDurationLabel() {
        
        let timeDiff = Int(endDate.timeIntervalSinceDate(startDate) * -1)
        
        let minutes = labs(timeDiff / 60)
        let seconds = labs(timeDiff % 60)
        
        if endDate.timeIntervalSince1970 > startDate.timeIntervalSince1970 {
            
            var timeString: String!
            if seconds < 10 {
                timeString = String(format: "Duration:  %i min", minutes)
            } else {
                timeString = String(format: "Duration:  %i min", minutes)
            }
            durationLabel.text = timeString
        } else {
            durationLabel.text = "N/A"
        }
        
        
    }
    
    @IBAction func selectCategoryPressed(sender: AnyObject) {
        performSegueWithIdentifier("toCategoryFromSave", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toCategoryFromSave" {
            let destinationVc = segue.destinationViewController as! CategorizeWorkoutViewController
            destinationVc.pickDelegate = self
        }
    }
    
    func didPickCategory(categoryIdentifier: NSNumber?) {
        if categoryIdentifier != nil {
            if categoryIdentifier == 0 {
                setToNoCategory()
                selectedCategory = nil
            } else {
                selectedCategory = categoryIdentifier
                colorIcon.backgroundColor = categoriesSingleton.getColorForIdentifier(categoryIdentifier)
                categoryLabel.text = categoriesSingleton.getStringForIdentifier(categoryIdentifier)
            }
        } else {
            selectedCategory = nil
            setToNoCategory()
        }
        
    }
    
    func setToNoCategory() {
        colorIcon.backgroundColor = UIColor.lightGrayColor()
        categoryLabel.text = "No category selected"
    }
    
    @IBAction func savePressed(sender: AnyObject) {
        if startDate != nil && endDate != nil {

            if endDate.timeIntervalSince1970 > startDate.timeIntervalSince1970 {
                QueryHealthKitWorkouts().workoutForTime(startDate, endDate: endDate, completion: { (result) in
                    if result == false {
                        if !CoreDataHelper().doesWorkoutExist(self.startDate) {
                            if CoreDataHelper().storeNewWorkout(self.startDate, endTime: self.endDate, title: self.nameTextField.text, description: self.descriptionTextView.text, category: self.selectedCategory) {
                                
                                let caloriesValue = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: self.calories)
                                let distanceValue = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: self.distance)
                                var healthKitWorkout: HKWorkout!
                                
                                if self.calories != 0 && self.distance != 0 {
                                    healthKitWorkout = HKWorkout(activityType: .Other, startDate: self.startDate, endDate: self.endDate, duration: abs(self.endDate.timeIntervalSinceDate(self.startDate)), totalEnergyBurned: caloriesValue, totalDistance: distanceValue, device: nil, metadata: nil)
                                } else if self.calories != 0 {
                                    healthKitWorkout = HKWorkout(activityType: .Other, startDate: self.startDate, endDate: self.endDate, duration: abs(self.endDate.timeIntervalSinceDate(self.startDate)), totalEnergyBurned: caloriesValue, totalDistance: nil, device: nil, metadata: nil)
                                } else if self.distance != 0 {
                                    healthKitWorkout = HKWorkout(activityType: .Other, startDate: self.startDate, endDate: self.endDate, duration: abs(self.endDate.timeIntervalSinceDate(self.startDate)), totalEnergyBurned: nil, totalDistance: distanceValue, device: nil, metadata: nil)
                                } else {
                                    healthKitWorkout = HKWorkout(activityType: .Other, startDate: self.startDate, endDate: self.endDate, duration: abs(self.endDate.timeIntervalSinceDate(self.startDate)), totalEnergyBurned: nil, totalDistance: nil, device: nil, metadata: nil)
                                }
                                
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                let hkStore = appDelegate.healthStore
                                
                                hkStore.saveObject(healthKitWorkout, withCompletion: { (success, error) in
                                    if success {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.navigationController?.popViewControllerAnimated(true)
                                        })
                                    } else {
                                        self.showAlert("Unable to store workout in HealthKit.")
                                    }
                                })
                                
                            } else {
                                self.showAlert("Error storing workout.")
                            }
                        } else {
                            self.showAlert("Workout with that start time already exists.")
                        }
                        
                    } else {
                        self.showAlert("End date can not be before start date.")
                    }
                })
            } else {
                self.self.showAlert("Workout with that start time already exists.")
            }
        }
    }
    
    func showAlert(message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}