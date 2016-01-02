//
//  WorkoutDetailViewController.swift
//  Apercu
//
//  Created by David Lantrip on 12/29/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import UIKit
import CorePlot

class WorkoutDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentWorkout: ApercuWorkout!
    
    @IBOutlet var hostView: CPTGraphHostingView!
    @IBOutlet var scrollView: CustomScrollView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var colorView: UIView!
    @IBOutlet private var segment: UISegmentedControl!
    @IBOutlet private var mostActiveSwitch: UISwitch!
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var colorLabel: UILabel!
    
    @IBOutlet private var colorButton: UIButton!
    @IBOutlet private var categorizeButton: UIButton!
    @IBOutlet private var optionsButton: UIButton!
    
    @IBOutlet private var tableViewHeight: NSLayoutConstraint!
    @IBOutlet private var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet private var graphConstraintBottom: NSLayoutConstraint!
    @IBOutlet private var graphConstraintHeight: NSLayoutConstraint!
    @IBOutlet private var graphConstraintLeading: NSLayoutConstraint!
    @IBOutlet private var graphConstraintTrailing: NSLayoutConstraint!
    
    var plotData = [String: [CPTScatterPlotField: Double]]()
    var workoutStats: [String: AnyObject]!
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    var graph: CPTXYGraph!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.translucent = false
        tabBarController!.tabBar.hidden = true
        categorizeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        optionsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        graph = CPTXYGraph(frame: self.view.bounds)
        graph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        graph.plotAreaFrame?.borderLineStyle = nil
        graph.plotAreaFrame?.masksToBorder = false
        graph.drawsAsynchronously = true
        
        hostView.hostedGraph = graph
        hostView.userInteractionEnabled = true
        hostView.allowPinchScaling = true
        
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.allowsMomentum = true
        
        let initialXrange = CPTPlotRange(location: 0, length: 10)
        plotSpace.xRange = initialXrange
        plotSpace.globalXRange = initialXrange
//        plotSpace.delegate = self
        
        
        ProcessWorkout().heartRatePlotDate(currentWorkout.getStartDate()!, end: currentWorkout.getEndDate()!, includeRaw: true, statsCompleted: { (stats) -> Void in
            // Stats for graph completed (min, max, avg, duration)
            // update graph
            
            
            }, completion: { (results) -> Void in
            // Stats for min and moderate time completed
            // update table view
                
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // Mark: - Graph View
    
    // Mark: - Text View
    
    // Mark: - IBActions for Button Presses
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        
    }
    
    @IBAction func activeSwitchChanged(sender: UISwitch) {
        
    }
    
    // Mark: UITableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
   
}