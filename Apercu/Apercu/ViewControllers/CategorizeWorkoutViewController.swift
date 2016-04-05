//
//  CategorizeWorkoutViewController.swift
//  Apercu
//
//  Created by David Lantrip on 1/24/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol PickedCategoryDelegate {
    func didPickCategory(categoryIdentifier: NSNumber?)
}

class CategorizeWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ColorPickerDelegate {
    
    @IBOutlet var colorButton: UIButton!
    @IBOutlet var descTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewBottom: NSLayoutConstraint!
    
    var pickDelegate: PickedCategoryDelegate!
    
    var categories = [Category]()
    let coreDataHelper = CoreDataHelper()
    var loadComplete = false
    
    var toolbar: UIToolbar!
    var workoutStart: NSDate?
    var workoutEnd: NSDate?
    var selectedCategory: NSNumber!
    var selectedIndexPathRow: NSNumber = 0
    var shouldScrollToBottom = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        
        descTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CategorizeWorkoutViewController.hideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CategorizeWorkoutViewController.showKeyboard(_:)), name: UIKeyboardDidShowNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        categories = CoreDataHelper().getAllCategories()
        tableView.reloadData()
        updateTextField()
        
        if shouldScrollToBottom {
            scrollToBottom()
        }
        
        
        if selectedCategory == nil || selectedCategory == 0 {
            colorButton.setTitle("New Color", forState: .Normal)
        } else {
            colorButton.setTitle("Change Color", forState: .Normal)
        }
        

    }
    
    func updateTextField() {
        if selectedCategory != nil && categories.count > 0 {
            if let desc = CategoriesSingleton.sharedInstance.getStringForIdentifier(selectedCategory) {
                descTextField.text = desc
            }
        }
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categories.count > 0 {
            return categories.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryReuse", forIndexPath: indexPath) as! CategoryCell
        cell.colorView.layer.cornerRadius = 13
        
        if categories.count > 0 {
            cell.colorView.hidden = false
            cell.label.text = categories[indexPath.row].title
            cell.colorView.backgroundColor = categories[indexPath.row].color as? UIColor
        } else {
            cell.colorView.hidden = true
            if loadComplete {
                cell.label.text = "Loading categories..."
            } else {
                cell.label.text = "No categories found."
            }
        }
        
        if selectedCategory != nil && selectedCategory == categories[indexPath.row].identifier {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCategory = categories[indexPath.row].identifier
        
        tableView.reloadData()
        if (workoutStart != nil && workoutEnd != nil) {
            CoreDataHelper().updateCategory(workoutStart!, endDate: workoutEnd!, categoryId: selectedCategory)
        }
        updateTextField()
        
        if pickDelegate != nil {
            CategoriesSingleton.sharedInstance.updateCategoryInfo()
            pickDelegate.didPickCategory(categories[indexPath.row].identifier)
        }
        
        if indexPath.row == 0 {
            colorButton.setTitle("New Color", forState: .Normal)
        } else {
            colorButton.setTitle("Change Color", forState: .Normal)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            CoreDataHelper().removeCategory(categories[indexPath.row].identifier!)
            categories.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            categories = CoreDataHelper().getAllCategories()
            tableView.reloadData()
            updateTextField()
        }
    }
    
    // MARK: - Text View
    
    func showToolbar(textField: UITextField) {
        if toolbar == nil {
            toolbar = UIToolbar()
            toolbar.sizeToFit()
            let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(CategorizeWorkoutViewController.hideKeyboard(_:)))
            
            toolbar.setItems([spacer, doneButton], animated: false)
            toolbar.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
            toolbar.tintColor = UIColor.redColor()
        }
        
        textField.inputAccessoryView = toolbar
    }
    
    func loadDescIntoTextField() {
        if let desc = categories[selectedIndexPathRow.integerValue].title {
            descTextField.text = desc
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        showToolbar(textField)
        return true
    }
    
    func hideKeyboard(sender: AnyObject) {
        if descTextField.isFirstResponder() {
            descTextField.resignFirstResponder()
        }
        
        if selectedCategory != 0 {
            
            tableViewBottom.constant = 0;
            if descTextField.text != "" {
                if let categoryToUpdate = selectedCategory {
                    CoreDataHelper().updateCategoryDescription(categoryToUpdate, desc: (descTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))!)
                }
            }
        }
        
        categories = CoreDataHelper().getAllCategories()
        tableView.reloadData()
    }
    
    func showKeyboard(sender: NSNotification) {
        let info = sender.userInfo
        let keyboardDict = info![UIKeyboardFrameBeginUserInfoKey] as? NSValue
        let keyboardSize = keyboardDict?.CGRectValue()
        
        tableViewBottom.constant = keyboardSize!.size.height
        
        if selectedCategory != nil {
//            tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: selectedCategory.integerValue, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
    
    @IBAction func colorButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("toColorPicker", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toColorPicker" {
            let destinationVC = segue.destinationViewController as! ColorPickerViewController
            
            if selectedCategory == nil || selectedCategory == 0 {
                destinationVC.isNewColor = 1
            } else {
                destinationVC.isNewColor = 0
                let categoryToSend = categories[selectedIndexPathRow.integerValue]
                let identifierToSend = selectedCategory
//                let categoryToSend: Category = categories[selectedCategory.integerValue]
                destinationVC.color = CategoriesSingleton.sharedInstance.getColorForIdentifier(selectedCategory)
                destinationVC.categoryNumber = identifierToSend
            }
            
            destinationVC.delegate = self
        }
    }
    
    func didAddNewColor() {
        shouldScrollToBottom = true
    }
    
    func scrollToBottom() {
        let tableCount = tableView.numberOfRowsInSection(0)
        
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: tableCount - 1, inSection: 0), animated: true, scrollPosition: .Bottom)
        selectedCategory = categories[tableCount - 1].identifier
        selectedIndexPathRow = tableCount - 1
        CoreDataHelper().updateCategory(workoutStart!, endDate: workoutEnd!, categoryId: selectedCategory)
        loadDescIntoTextField()
    }
}