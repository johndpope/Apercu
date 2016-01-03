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

class WorkoutDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CPTPlotDelegate, CPTPlotDataSource {
    
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
    
    var plots = [String: ApercuPlot]()
    var heatmapPlots: [ApercuPlot]!
    var workoutStats: [String: AnyObject]!
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    var graph: CPTXYGraph!
    
    var min: Double!
    var plotMin: Double!
    var max: Double!
    var plotMax: Double!
    var duration: Double!
    var avg: Double!
    var bpm: [Double]!
    var time: [Double]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.translucent = false
        tabBarController!.tabBar.hidden = true
        categorizeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        optionsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        segment.setEnabled(false, forSegmentAtIndex: 1)
        
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
        plotSpace.delegate = self
        
        
        
        ProcessWorkout().heartRatePlotDate(currentWorkout.getStartDate()!, end: currentWorkout.getEndDate()!, includeRaw: true, statsCompleted: { (stats) -> Void in
            // Stats for graph completed (min, max, avg, duration)
            // update graph
            self.min = stats["min"] as! Double
            self.plotMin = self.min - 3.0
            self.max = stats["max"] as! Double
            self.plotMax = self.max + 3.0
            self.avg = stats["avg"] as! Double
            self.duration = stats["duration"] as! Double
            self.bpm = stats["bpm"] as! [Double]
            self.time = stats["time"] as! [Double]
            
            let scatterPlots = GraphPlotSetup().detailPlotSetup()
            let plotDataCreator = GraphDataSetup()
            
            self.plots["Main"] = ApercuPlot(plot: scatterPlots[0], data: plotDataCreator.createMainPlotData(self.bpm, time: self.time))
            self.plots["Average"] = ApercuPlot(plot: scatterPlots[1], data: plotDataCreator.createAveragePlotData(self.avg, duration: self.duration))
            self.plots["Top Fill"] = ApercuPlot(plot: scatterPlots[2], data: plotDataCreator.createTopFillPlotData(self.duration))
            self.plots["Bottom Fill"] = ApercuPlot(plot: scatterPlots[3], data: plotDataCreator.createBottomFillPlotData(self.duration))
            self.plots["Zero Line"] = ApercuPlot(plot: scatterPlots[4], data: plotDataCreator.createZeroLineData(self.duration))
            
            // show plots
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                GraphAxisSetUp().initialSetup((self.graph.axisSet as? CPTXYAxisSet)!, duration: self.duration, min: self.min)
                
                for (_, plot) in self.plots {
                    plot.plot.dataSource = self
                }
                
                
            })
            
            
            }, completion: { (results) -> Void in
            // Stats for min and moderate time completed
            // update table view
                
            GraphHeatmap().heatmapRawData(self.bpm, min: self.min, max: self.max, completion: { (colorNumber) -> Void in
                
                self.heatmapPlots = GraphPlotSetup().createHeatmapPlot(colorNumber, time: self.time, yMin: self.plotMin, yMax: self.plotMax)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.segment.setEnabled(true, forSegmentAtIndex: 1)
                })
            })
        })
        
        
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // Mark: - Graph Delegates
    
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        let identifier = plot.identifier as! String
        
        if identifier == "Main" {
            return plots["Main"]!.dataCount()
        } else if identifier == "Average" {
            return plots["Average"]!.dataCount()
        } else if identifier == "Top Fill" {
            return plots["Top Fill"]!.dataCount()
        } else if identifier == "Bottom Fill" {
            return plots["Bottom Fill"]!.dataCount()
        } else if identifier == "Zero Line" {
            return plots["Zero Line"]!.dataCount()
        } else {
            return
        }
        
    }
    
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