//
//  CategoryFilterViewController.swift
//  Apercu
//
//  Created by David Lantrip on 12/26/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CategoryFilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var removeAllButton: UIButton!
    @IBOutlet var selectAllButton: UIButton!
    
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    var categories = [Category]()
    var selectedCategories = [NSNumber]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController!.tabBar.hidden = true
        
        removeAllButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectAllButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if defs?.objectForKey("selectedCategories") != nil {
            selectedCategories = defs?.objectForKey("selectedCategories") as! [NSNumber]
        }
        
        defs?.setObject(nil, forKey: "categoryBlacklist")
        
        categories = CoreDataHelper().getAllCategories()
    }
    
    @IBAction func selectAllCategories(sender: UIButton) {
        selectedCategories.removeAll()
        for category in categories {
            selectedCategories.append(category.identifier!)
        }
        storeSelectedCategories()
        tableView.reloadData()
    }
    
    @IBAction func removeAllCategories(sender: UIButton) {
        selectedCategories.removeAll()
        storeSelectedCategories()
        tableView.reloadData()
    }
    
    func isCategorySelected(identifier: NSNumber) -> Bool {
        return selectedCategories.contains(identifier)
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryCell
        let categoryForRow = categories[indexPath.row]
        
        cell.colorView.hidden = false
        cell.accessoryType = .None
        
        let colorViewCenter = cell.colorView.center
        let newColorViewFrame = CGRectMake(cell.colorView.frame.origin.x, cell.colorView.frame.origin.y, 25, 25)
        cell.colorView.frame = newColorViewFrame
        cell.colorView.layer.cornerRadius = 12.5
        cell.colorView.center = colorViewCenter
        
        cell.colorView.backgroundColor = categoryForRow.color as? UIColor
        cell.label.text = categoryForRow.title
        
        if isCategorySelected(categoryForRow.identifier!) {
            cell.accessoryType = .Checkmark
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCategory = categories[indexPath.row]
        
        if !selectedCategories.contains(selectedCategory.identifier!) {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            selectedCategories.append(selectedCategory.identifier!)
            storeSelectedCategories()
            
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCategory = categories[indexPath.row]
        
        if selectedCategories.contains(selectedCategory.identifier!) {
            let indexOfIdentifier = selectedCategories.indexOf(selectedCategory.identifier!)
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
            selectedCategories.removeAtIndex(indexOfIdentifier!)
            storeSelectedCategories()
            
        }
    }
    
    func storeSelectedCategories() {
        defs?.setObject(selectedCategories, forKey: "selectedCategories");
    }
    
}