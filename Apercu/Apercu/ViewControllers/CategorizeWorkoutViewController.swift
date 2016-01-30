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

class CategorizeWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var colorButton: UIButton!
    @IBOutlet var descTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewBottom: NSLayoutConstraint!
    
    var categories = [Category]()
    let coreDataHelper = CoreDataHelper()
    var loadComplete = false
    
    var toolbar: UIToolbar!
    var workoutStart: NSDate!
    var workoutEnd: NSDate!
    var selectedCategory: NSNumber!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showKeyboard:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        categories = coreDataHelper.getAllCategories()
        tableView.reloadData()
        updateTextField()
    }
    
    func updateTextField() {
        if selectedCategory != nil && categories.count > 0 {
            if let desc = categories[selectedCategory.integerValue].title {
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
        cell.colorView.layer.cornerRadius = 12.5
        
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
        
        if selectedCategory != nil && indexPath.row == selectedCategory {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCategory = categories[indexPath.row].identifier
        tableView.reloadData()
        coreDataHelper.updateCategory(workoutStart, endDate: workoutEnd, categoryId: selectedCategory)
        updateTextField()
    }
    
    // MARK: - Text View
    
    func showToolbar(textField: UITextField) {
        if toolbar == nil {
            toolbar = UIToolbar()
            toolbar.sizeToFit()
            let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "hideKeyboard:")
            
            toolbar.setItems([spacer, doneButton], animated: false)
            toolbar.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
            toolbar.tintColor = UIColor.redColor()
        }
        
        textField.inputAccessoryView = toolbar
    }
    
    func loadDescIntoTextField() {
        if let desc = categories[selectedCategory.integerValue].title {
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
        
        tableViewBottom.constant = 0;
        if descTextField.text != "" {
            if let categoryToUpdate = selectedCategory {
                coreDataHelper.updateCategoryDescription(categoryToUpdate, desc: (descTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))!)
            }
        }
    }
    
    func showKeyboard(sender: NSNotification) {
        let info = sender.userInfo
        let keyboardDict = info![UIKeyboardFrameBeginUserInfoKey] as? NSValue
        let keyboardSize = keyboardDict?.CGRectValue()
        
        tableViewBottom.constant = keyboardSize!.size.height
        
        if selectedCategory != nil {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: selectedCategory.integerValue, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
}