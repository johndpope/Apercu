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

class CategorizeWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var colorButton: UIButton!
    @IBOutlet var descTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var categories = [Category]()
    let coreDataHelper = CoreDataHelper()
    var loadComplete = false
    
    var workoutStart: NSDate!
    var selectedCategory: NSNumber!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        categories = coreDataHelper.getAllCategories()
        tableView.reloadData()
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
        coreDataHelper.updateCategory(workoutStart, categoryId: categories[indexPath.row].identifier!)
    }
}