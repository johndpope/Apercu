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
import HealthKit

class WorkoutDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CPTPlotSpaceDelegate, CPTPlotDataSource, ActiveSliderChanged, UITextViewDelegate, ProcessArrayDelegate {
    
    @IBOutlet var noDataFoundLabel: UILabel!
    var currentWorkout: ApercuWorkout!
    var startDate: NSDate!
    var coreDataWorkout: Workout?
    var healthKitWorkout: HKWorkout?
    var allWorkouts: [ApercuWorkout]!
    var allWorkoutAverages: [String: Double?]!
    var workoutRawValues: [String: Double?]!
    var allWorkoutStats = [Int: [String: AnyObject]]()
    var allWorkoutHeatmapBands = [Int: [CPTLimitBand]]()
    var workoutMainIsFinished = [Bool]()
    var workoutHeatmapIsFinished = [Bool]()
    
    var currentWorkoutIndex = 0
    
    @IBOutlet var hostView: CPTGraphHostingView!
    @IBOutlet var scrollView: CustomScrollView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var colorView: UIView!
    @IBOutlet private var segment: UISegmentedControl!
    @IBOutlet private var activeView: ActiveSlider!
    @IBOutlet private var descTextView: UITextView!
    @IBOutlet var titleTextView: UITextView!
    
    @IBOutlet var colorViewTrailing: NSLayoutConstraint!
    @IBOutlet var colorViewWidth: NSLayoutConstraint!
    @IBOutlet private var colorLabel: UILabel!
    @IBOutlet private var categorizeButton: UIButton!
    
    @IBOutlet private var tableViewHeight: NSLayoutConstraint!
    @IBOutlet private var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet private var graphConstraintBottom: NSLayoutConstraint!
    @IBOutlet private var graphConstraintHeight: NSLayoutConstraint!
    @IBOutlet private var graphConstraintLeading: NSLayoutConstraint!
    @IBOutlet private var graphConstraintTrailing: NSLayoutConstraint!
    
    @IBOutlet var descTextViewHeight: NSLayoutConstraint!
    @IBOutlet var titleTextViewHeight: NSLayoutConstraint!
    
    @IBOutlet var previousToolbarButton: UIBarButtonItem!
    @IBOutlet var nextToolbarButton: UIBarButtonItem!
    @IBOutlet var centerToolbarButton: UIBarButtonItem!
    
    var plots = [String: ApercuPlot]()
    var limitBands: [CPTLimitBand]!
    var workoutStats: [String:AnyObject]!
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    var graph: CPTXYGraph!
    var axisSet: CPTXYAxisSet!
    var keyboardToolbar: UIToolbar!
    var comparisonToolbar: UIToolbar!
    
    var min: Double!
    var plotMin: Double!
    var max: Double!
    var plotMax: Double!
    var duration: Double!
    var avg: Double!
    var bpm: [Double]!
    var time: [Double]!
    var distance: Double!
    var calories: Double!
    var moderateIntensityTime: Double!
    var highIntensityTime: Double!
    var shouldInterupt = false
    
    var tableStrings: [NSAttributedString]!
    var tableValues: [NSAttributedString]?
    var comparisonAverages: [String: Double]?
    
    var backgroundColor = CPTColor(componentRed: 89.0 / 255.0, green: 87.0 / 255.0, blue: 84.0 / 255.0, alpha: 1.0)
    var alternateCellColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    var goingToNewYAxis = false
    let plotDataCreator = GraphDataSetup()
    let graphMostActive = GraphMostActive()
    let coreDataHelper = CoreDataHelper()
    var averagingInProgress = false
    var mostActiveInProgress = false
    var showMostActive = false
    var activeDuration = 0
    var segmentSwitching = false
    var loadingNewWorkout = true
    var loadingHeatmap = true
    var loadingStrings = true
    var allAveragesInProgress = false
    
    var currentParseIndex = 0
    var finalParseIndex: Int!
    
    var nextBarButton: UIBarButtonItem!
    var titlePlaceHolder = "Add title.."
    var descPlaceHolder = "Add workout notes.."
    
    var processArray = ProcessArray()
    var processingIsDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWorkout()
        
        navigationController?.navigationBar.translucent = false
        
        categorizeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        //        segment.setEnabled(false, forSegmentAtIndex: 1)
        activeView.delegate = self
        colorView.layer.cornerRadius = 13
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 30.0
        tableView.rowHeight = UITableViewAutomaticDimension
        updateTableHeight()
        
        automaticallyAdjustsScrollViewInsets = false
        
        graph = CPTXYGraph(frame: self.view.bounds)
        graph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        graph.plotAreaFrame?.borderLineStyle = nil
        graph.plotAreaFrame?.masksToBorder = false
        graph.drawsAsynchronously = true
        graph.plotAreaFrame?.plotArea?.fill = CPTFill(color: backgroundColor)
        graph.backgroundColor = backgroundColor.cgColor
        axisSet = graph.axisSet as? CPTXYAxisSet
        
        hostView.hostedGraph = graph
        hostView.userInteractionEnabled = true
        hostView.allowPinchScaling = true
        
        processArray.finishedDelegate = self
        
        descTextView.delegate = self
        descTextView.layer.cornerRadius = 6.0
        titleTextView.delegate = self
        titleTextView.layer.cornerRadius = 6.0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WorkoutDetailViewController.hideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WorkoutDetailViewController.showKeyboard(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.allowsMomentum = true
        
        let initialXrange = CPTPlotRange(location: 0, length: 10)
        plotSpace.xRange = initialXrange
        plotSpace.globalXRange = initialXrange
        plotSpace.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WorkoutDetailViewController.screenRotated(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        if allWorkouts != nil {
            workoutMainIsFinished = [Bool](count: allWorkouts.count, repeatedValue: false)
            workoutHeatmapIsFinished = [Bool](count: allWorkouts.count, repeatedValue: false)
            updateComparisonLabels()
            navigationController?.toolbarHidden = false
            finalParseIndex = allWorkouts.count - 1
        } else {
            workoutHeatmapIsFinished.append(false)
            workoutMainIsFinished.append(false)
            navigationController?.toolbarHidden = true
        }
        
        tableStrings = GraphTableStrings().allHeaderStrings()
        
        GraphAxisSetUp().initialSetup((self.graph.axisSet as? CPTXYAxisSet)!, duration: 60, min: 50)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            self.processCurrentWorkout(0)
            if self.allWorkouts != nil {
                self.parseWorkoutData(self.currentParseIndex)
            }
        })
        
    }
    
    func processingComplete(results: [String: Double?]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.allWorkoutAverages = results
            self.generateComparisonStats()
            self.loadingStrings = false
            self.processingIsDone = true
        })
    }
    
    func parseWorkoutData(index: Int) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let workoutForIndex = self.allWorkouts[index]
            ProcessWorkout().heartRatePlotDate(workoutForIndex.getStartDate()!, end: workoutForIndex.getEndDate()!, includeRaw: true, statsCompleted: { (stats) in
                self.allWorkoutStats[index] = stats;
                
                }, completion: { (results) in
                    self.allWorkoutStats[index] = results;
                    self.workoutMainIsFinished[index] = true
                    
                    if results != nil && self.bpm != nil && self.bpm.count > 0 {
                        self.calculateHeatmapGraph(index, bpm: results["bpm"] as! [Double], time: results["time"] as! [Double], min: results["min"] as! Double, max: results["max"] as! Double, yMin: results["min"] as! Double, yMax: results["max"] as! Double, addToGraph: false)
                    } else {
                        //                        self.setupTableStrings(self.allWorkoutStats[index])
                        self.loadingHeatmap = false
                        self.loadingStrings = false
                    }
                    
                    
                    if self.shouldInterupt {
                        self.parseWorkoutData(self.currentWorkoutIndex)
                        self.shouldInterupt = false
                    } else {
                        
                        if self.currentParseIndex < self.finalParseIndex {
                            self.currentParseIndex += 1
                            self.parseWorkoutData(self.currentParseIndex)
                        }
                        
                    }
            })
        })
        
        
    }
    
    func loadWorkout() {
        if allWorkouts != nil {
            healthKitWorkout = allWorkouts[currentWorkoutIndex].healthKitWorkout
            startDate = allWorkouts[currentWorkoutIndex].getStartDate()
        }
        coreDataWorkout = coreDataHelper.getCoreDataWorkout(startDate)
        currentWorkout = ApercuWorkout(healthKitWorkout: healthKitWorkout, workout: coreDataWorkout)
        
        setTitle()
        setDescriptionTextView()
        updateCategoryDisplay()
    }
    
    func setupWorkoutStats(stats: [String: AnyObject]) {
        min = stats["min"] as! Double
        
        if min > 60 + 3.0 {
            plotMin = 60
        } else {
            plotMin = self.min - 3.0
        }
        
        max = stats["max"] as! Double
        
        if max > IntensityThresholdSingleton.sharedInstance.maximumHeatRate - 3.0 {
            plotMax = self.max + 3.0
        } else {
            plotMax = IntensityThresholdSingleton.sharedInstance.maximumHeatRate
        }
        
        avg = stats["avg"] as! Double
        duration = stats["duration"] as! Double
        bpm = stats["bpm"] as! [Double]
        time = stats["time"] as! [Double]
        plots["Average"] = ApercuPlot(plot: GraphPlotSetup().createAveragePlot(), data: self.plotDataCreator.createAveragePlotData(self.avg, duration: self.duration))
    }
    
    func setupNormalPlots(shouldAddPlots: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            () -> Void in
            
            if self.segment.selectedSegmentIndex == 0 {
                if shouldAddPlots {
                    self.removeAllPlots()
                    self.addPlotsForNormalView()
                    
                    if self.showMostActive == true {
                        self.findMostActive()
                    }
                }
                
                if self.axisSet.yAxis?.backgroundLimitBands == nil {
                    self.addIntensityLimitBands()
                }
            }
            
            self.graph.reloadData()
            self.setFullXRange()
            self.goingToNewYAxis = true
            self.setFullYRange()
            self.goingToNewYAxis = false
            GraphAxisSetUp().updateLabelingPolicy(self.duration, axisSet: self.axisSet)
        })
    }
    
    func calculateHeatmapGraph(workoutIndex: Int, bpm: [Double], time: [Double], min: Double, max: Double, yMin: Double, yMax: Double, addToGraph: Bool) {
        
        if workoutHeatmapIsFinished[currentWorkoutIndex] && allWorkoutHeatmapBands[currentWorkoutIndex] != nil {
            self.limitBands = allWorkoutHeatmapBands[workoutIndex]
            if addToGraph {
                self.setupHeatmapGraph()
            }
        } else {
            GraphHeatmap().heatmapRawData(bpm, min: min, max: max, completion: {
                (colorNumber) -> Void in
                let workoutLimitBands = GraphPlotSetup().createHeatmapLimitBands(colorNumber, time: time, yMin: yMin, yMax: yMax)
                
                if addToGraph && self.currentWorkoutIndex == workoutIndex && self.segment.selectedSegmentIndex == 1 {
                    dispatch_async(dispatch_get_main_queue(), {
                        () -> Void in
                        self.removeAllPlots()
                        self.limitBands = workoutLimitBands
                        
                        for band in workoutLimitBands {
                            self.axisSet?.xAxis?.addBackgroundLimitBand(band)
                        }
                        
                        if self.showMostActive == true {
                            self.findMostActive()
                        }
                        self.loadingHeatmap = false
                        
                        if self.processArray.shouldPause {
                            self.processArray.resumeProcessing()
                        }
                    })
                } else {
                    self.allWorkoutHeatmapBands[workoutIndex] = workoutLimitBands
                    self.workoutHeatmapIsFinished[workoutIndex] = true
                }
            })
        }
    }
    
    func setupHeatmapGraph() {
        dispatch_async(dispatch_get_main_queue(), {
            () -> Void in
            if self.segment.selectedSegmentIndex == 1 {
                let axisSet = self.graph.axisSet as? CPTXYAxisSet
                axisSet?.yAxis?.removeAllBackgroundLimitBands()
                axisSet?.xAxis?.removeAllBackgroundLimitBands()
                
                let currentBands = self.allWorkoutHeatmapBands[self.currentWorkoutIndex]
                for band in currentBands! {
                    self.axisSet?.xAxis?.addBackgroundLimitBand(band)
                }
                
                if self.showMostActive == true {
                    self.findMostActive()
                }
                self.loadingHeatmap = false
            }
            
        })
    }
    
    func setupTableStrings(stats: [String: AnyObject]?) {
        
        if stats != nil && stats!["mod"] != nil {
            self.moderateIntensityTime = stats!["mod"] as! Double
        } else {
            self.moderateIntensityTime = 0.0
        }
        
        if stats != nil && stats!["high"] as? Double != nil {
            self.highIntensityTime = stats!["high"] as! Double
            
            if self.highIntensityTime == nil {
                self.highIntensityTime = 0.0
            }
        } else {
            self.highIntensityTime = 0.0
        }
        
        let milesUnit = HKUnit.mileUnit()
        self.distance = self.currentWorkout.healthKitWorkout?.totalDistance?.doubleValueForUnit(milesUnit)
        
        let caloriesUnit = HKUnit.kilocalorieUnit()
        self.calories = self.currentWorkout.healthKitWorkout?.totalEnergyBurned?.doubleValueForUnit(caloriesUnit)
        
        let description: Double!
        
        if self.currentWorkout.healthKitWorkout?.workoutActivityType != nil {
            description = Double(( self.currentWorkout.healthKitWorkout?.workoutActivityType.rawValue)!)
        } else {
            description = nil
        }
        
        
        let rawValues: [String: Double?] = ["start": (self.currentWorkout.getStartDate()?.timeIntervalSince1970)!,"duration": self.currentWorkout.getEndDate()?.timeIntervalSinceDate(self.currentWorkout.getStartDate()!),"moderate": self.moderateIntensityTime, "high": self.highIntensityTime, "distance": self.distance,"calories": self.calories,"desc": description]
        self.workoutRawValues = rawValues
        
        self.tableValues = GraphTableStrings().allValueStrings(rawValues)
        
        dispatch_async(dispatch_get_main_queue(), {
            () -> Void in
            
            if self.allWorkoutAverages == nil {
                self.tableView.reloadData()
                self.view.layoutIfNeeded()
                self.updateTableHeight()
                self.tableView.reloadData()
                self.updateTableHeight()
                self.loadingStrings = false
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                if self.allWorkouts != nil {
                    if self.allWorkoutAverages == nil && !self.allAveragesInProgress {
                        self.allAveragesInProgress = true
                        
                        self.processArray.processGroup(self.allWorkouts, completion: { (results) in
                            
                        })
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.generateComparisonStats()
                            self.loadingStrings = false
                        })
                        
                    }
                }
            })
        })
    }
    
    func processCurrentWorkout(workoutId: Int) {
        loadingNewWorkout = true
        loadingHeatmap = true
        loadingStrings = true
        
        
        if let currentStats = allWorkoutStats[workoutId] {
            setupWorkoutStats(currentStats)
            setupNormalPlots(false)
            
            dispatch_async(dispatch_get_main_queue(), {
                if currentStats["bpm"] == nil || (currentStats["bpm"] as! [Double]).count == 0 {
                    self.noDataFoundLabel.hidden = false
                } else {
                    self.noDataFoundLabel.hidden = true
                }
            })
            
            
            if segment.selectedSegmentIndex == 1 {
                //                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.calculateHeatmapGraph(self.currentWorkoutIndex, bpm: self.bpm, time: self.time, min: self.min, max: self.max, yMin: self.plotMin, yMax: self.plotMax, addToGraph: true )
                //                })
            } else {
                self.loadingHeatmap = false
            }
            setupTableStrings(currentStats)
            loadingNewWorkout = false
            
        } else {
            ProcessWorkout().heartRatePlotDate(self.currentWorkout.getStartDate()!, end: self.currentWorkout.getEndDate()!, includeRaw: true, statsCompleted: {
                (stats) -> Void in
                // Stats for graph completed (min, max, avg, duration)
                // update graph
                dispatch_async(dispatch_get_main_queue(), {
                    if stats["bpm"] == nil || (stats["bpm"] as! [Double]).count == 0 {
                        self.noDataFoundLabel.hidden = false
                    } else {
                        self.noDataFoundLabel.hidden = true
                    }
                })
                
                self.setupWorkoutStats(stats)
                
                // show plots
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    self.setupNormalPlots(true)
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        () -> Void in
                        if self.segment.selectedSegmentIndex == 0 {
                            self.calculateHeatmapGraph(self.currentWorkoutIndex, bpm: stats["bpm"] as! [Double], time: stats["time"] as! [Double], min: stats["min"] as! Double, max: stats["max"] as! Double, yMin: self.plotMin, yMax: self.plotMax, addToGraph: false)
                        } else {
                            self.calculateHeatmapGraph(self.currentWorkoutIndex, bpm: stats["bpm"] as! [Double], time: stats["time"] as! [Double], min: stats["min"] as! Double, max: stats["max"] as! Double, yMin: self.plotMin, yMax: self.plotMax, addToGraph: true)
                        }
                        self.loadingHeatmap = false
                    })
                })
                
                }, completion: {
                    (results) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        if results == nil || results["bpm"] == nil || (results["bpm"] as! [Double]).count == 0 {
                            self.noDataFoundLabel.hidden = false
                        } else {
                            self.noDataFoundLabel.hidden = true
                        }
                    })
                    
                    self.setupTableStrings(results)
                    //                    self.loadingNewWorkout = false
            })
        }
    }
    
    func generateComparisonStats() {
        if workoutRawValues != nil && allWorkoutAverages != nil {
            tableValues = GraphTableStrings().valueStringWithComparison(workoutRawValues, averages: allWorkoutAverages)
            tableView.reloadData()
            updateTableHeight()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let screenRect = UIScreen.mainScreen().bounds
        graphConstraintBottom.constant = 10
        graphConstraintLeading.constant = 20
        graphConstraintTrailing.constant = 20
        graphConstraintHeight.constant = 0.5 * screenRect.size.height
        
        if let tabBarCont = self.tabBarController {
            if tabBarCont.tabBar.hidden == false {
                tabBarCont.tabBar.hidden = true
            }
        }
        
        loadWorkout()
    }
    
    func updateCategoryDisplay() {
        if currentWorkout.workout != nil {
            if let currentCategory = currentWorkout.workout!.category {
                let categoryHelper = CategoriesSingleton.sharedInstance
                categoryHelper.updateCategoryInfo()
                let colorViewColor = categoryHelper.getColorForIdentifier(currentCategory)
                
                if colorViewColor == UIColor.clearColor() {
                    showColorView(false)
                } else {
                    showColorView(true)
                }
                colorView.backgroundColor = colorViewColor
                
                colorLabel.text = categoryHelper.getStringForIdentifier(currentCategory)
            } else {
                colorLabel.text = "No category selected"
            }
        } else {
            showColorView(false)
        }
    }
    
    func showColorView(show: Bool) {
        if show {
            colorViewWidth.constant = 25
            colorViewTrailing.constant = 10
        } else {
            colorViewWidth.constant = 0
            colorViewTrailing.constant = 0
        }
    }
    
    
    // MARK: - Graph Helpers
    
    func setFullXRange() {
        let xMin = 0.0
        let xMax = duration
        
        let xRange = CPTPlotRange(location: xMin, length: xMax)
        
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.xRange = xRange
        plotSpace.globalXRange = xRange
    }
    
    func setFullYRange() {
        let yMin = plotMin
        
        let yRangeToFitData = plotMax - plotMin
        let yRangeForMaxHr = IntensityThresholdSingleton.sharedInstance.maximumHeatRate - plotMin
        let yLengthMax = fmax(yRangeToFitData, yRangeForMaxHr)
        
        let yRange = CPTPlotRange(location: yMin, length: yLengthMax)
        plotMax = yMin + yLengthMax
        
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.yRange = yRange
        plotSpace.globalYRange = yRange
    }
    
    func addPlotsForNormalView() {
        segmentSwitching = true
        addIntensityLimitBands()
        addMainPlots()
        segmentSwitching = false
    }
    
    func addPlotsForHeatmap(shouldAddMainPlots: Bool, highPriority: Bool) {
        segmentSwitching = true
        
        //        dispatch_async(dispatch_get_main_queue(), {
        if self.workoutHeatmapIsFinished[self.currentWorkoutIndex] && self.allWorkoutHeatmapBands[self.currentWorkoutIndex] != nil {
            let currentBands = self.allWorkoutHeatmapBands[self.currentWorkoutIndex]
            for band in currentBands! {
                self.axisSet?.xAxis?.addBackgroundLimitBand(band)
            }
        } else {
            guard self.bpm != nil && self.time != nil && self.max != nil && self.min != nil && self.plotMin != nil && self.plotMax != nil else {
                return
            }
            
            if highPriority {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    self.calculateHeatmapGraph(self.currentWorkoutIndex, bpm: self.bpm, time: self.time, min: self.min, max: self.max, yMin: self.plotMin, yMax: self.plotMax, addToGraph: true)
                })
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    self.calculateHeatmapGraph(self.currentWorkoutIndex, bpm: self.bpm, time: self.time, min: self.min, max: self.max, yMin: self.plotMin, yMax: self.plotMax, addToGraph: true)
                })
            }
            
        }
        
        segmentSwitching = false
    }
    
    func addMainPlots() {
        if let activePlot = plots["Active"]?.plot {
            if !segmentSwitching {
                activePlot.dataSource = self
                graph.addPlot(activePlot)
            } else if showMostActive {
                activePlot.dataSource = self
                graph.addPlot(activePlot)
            }
        }
        
        if let averagePlot = plots["Average"]?.plot {
            averagePlot.dataSource = self
            if (graph.plotWithIdentifier("Average") == nil) {
                graph.addPlot(averagePlot)
            }
            
        }
        //
        //        if let mainPlot = plots["Main"]?.plot {
        //            mainPlot.dataSource = self
        //            graph.addPlot(mainPlot)
        //        }
    }
    
    func addIntensityLimitBands() {
        let intensityThresholds = IntensityThresholdSingleton.sharedInstance
        
        let maxHighIntensity = intensityThresholds.maximumHeatRate * 0.9
        let highIntensityThreshold = intensityThresholds.highIntensityThreshold
        let moderateIntensityTreshold = intensityThresholds.moderateIntensityThreshold
        
        let modThresholdRange = CPTPlotRange(location: moderateIntensityTreshold, length: highIntensityThreshold - moderateIntensityTreshold)
        let highThresholdRange = CPTPlotRange(location: maxHighIntensity, length: -(maxHighIntensity - highIntensityThreshold))
        
        let modBand = CPTLimitBand(range: modThresholdRange, fill: CPTFill(color: CPTColor(componentRed: 250.0 / 255.0, green: 10.0 / 255.0, blue: 10.0 / 255.0, alpha: 0.35)))
        let highBand = CPTLimitBand(range: highThresholdRange, fill: CPTFill(color: CPTColor(componentRed: 250.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.6)))
        
        axisSet.yAxis?.addBackgroundLimitBand(modBand)
        axisSet.yAxis?.addBackgroundLimitBand(highBand)
    }
    
    func removeAllPlots() {
        removeActivePlot()
        //
        //        for (_, element) in plots.enumerate() {
        //            if element.1.plot.graph != nil {
        //                graph.removePlot(element.1.plot)
        //            }
        //        }
        //
        let axisSet = graph.axisSet as? CPTXYAxisSet
        axisSet?.yAxis?.removeAllBackgroundLimitBands()
        axisSet?.xAxis?.removeAllBackgroundLimitBands()
    }
    
    func removeActivePlot() {
        if let activePlot = plots["Active"]?.plot {
            activePlot.dataSource = nil
        }
        if plots["Active"] != nil {
            
            graph.removePlotWithIdentifier("Active")
            //            plots["Active"] = nil
        }
    }
    
    func updateMainPlot(minTime: Double, maxTime: Double) {
        if !averagingInProgress && bpm != nil && bpm.count > 0 {
            averagingInProgress = true
            self.plots["Main"] = ApercuPlot(plot: GraphPlotSetup().createMainPlot(), data: plotDataCreator.createMainPlotData(self.bpm, time: self.time, minTime: minTime, maxTime: maxTime))
            
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                if self.graph.plotWithIdentifier("Main") == nil {
                    self.plots["Main"]?.plot.dataSource = self
                    self.graph.addPlot(self.plots["Main"]?.plot)
                }
                
                self.graph.reloadData()
                self.averagingInProgress = false
            })
        }
    }
    
    // MARK: - Graph Delegates
    
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        let identifier = plot.identifier as! String
        
        if identifier == "Main" {
            return plots["Main"]!.dataCount()
        } else if identifier == "Average" {
            return plots["Average"]!.dataCount()
        } else if identifier == "Active" {
            if plots["Active"]?.data != nil {
                return plots["Active"]!.dataCount()
            } else {
                return 0
            }
        } else {
            // for heatmap plots
            return 4
        }
    }
    
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        let identifier = plot.identifier as! String
        
        var fieldCoord: CPTScatterPlotField
        
        fieldCoord = fieldEnum == 0 ? CPTScatterPlotField.X : CPTScatterPlotField.Y
        
        if identifier == "Main" {
            return plots["Main"]!.data[Int(idx)][fieldCoord]
        } else if identifier == "Average" {
            return plots["Average"]!.data[Int(idx)][fieldCoord]
        } else if identifier == "Active" {
            return plots["Active"]!.data[Int(idx)][fieldCoord]
        } else {
            return 1
        }
    }
    
    func plotSpace(space: CPTPlotSpace, willChangePlotRangeTo newRange: CPTPlotRange, forCoordinate coordinate: CPTCoordinate) -> CPTPlotRange? {
        var updatedRange: CPTPlotRange!
        
        switch coordinate {
        case CPTCoordinate.X:
            if newRange.location.isLessThan(NSNumber(double: 0.0)) {
                var mutableRangeCopy: CPTMutablePlotRange!
                mutableRangeCopy = newRange.mutableCopy() as! CPTMutablePlotRange
                mutableRangeCopy.location = NSNumber(double: 0.0)
                updatedRange = mutableRangeCopy
            } else {
                updatedRange = newRange
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    () -> Void in
                    self.updateMainPlot(newRange.location.doubleValue, maxTime: newRange.location.doubleValue + newRange.length.doubleValue)
                })
                
                GraphAxisSetUp().updateLabelingPolicy(newRange.length.doubleValue, axisSet: axisSet)
            }
        case CPTCoordinate.Y:
            if goingToNewYAxis {
                updatedRange = newRange
            } else {
                let plotSpace = space as! CPTXYPlotSpace
                updatedRange = plotSpace.yRange
            }
        default:
            break
        }
        
        return updatedRange
    }
    
    // MARK: - IBActions for Button Presses
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            // Normal Graph
            removeAllPlots()
            addPlotsForNormalView()
        } else {
            let axisSet = graph.axisSet as? CPTXYAxisSet
            axisSet?.yAxis?.removeAllBackgroundLimitBands()
            axisSet?.xAxis?.removeAllBackgroundLimitBands()
            self.addPlotsForHeatmap(true, highPriority: true)
            
            if !workoutHeatmapIsFinished[currentWorkoutIndex] {
                shouldInterupt = true
                processArray.shouldPause = true
            }
            // Heatmap
            //                        removeAllPlots()
            //                        setupHeatmapGraph()
            ////                        addPlotsForHeatmap()
        }
    }
    
    // MARK: - UITableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableValues == nil {
            return 1
        } else {
            return tableValues!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StatReuse", forIndexPath: indexPath) as! SingleLineStatCell
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = alternateCellColor
        } else {
            cell.backgroundColor = UIColor.clearColor()
        }
        
        if tableValues == nil {
            cell.stringLabel.text = "Loading stats..."
            cell.valueLabel.text = ""
        } else {
            cell.stringLabel.attributedText = tableStrings[indexPath.row]
            cell.valueLabel.attributedText = tableValues![indexPath.row]
        }
        
        return cell
    }
    
    func updateTableHeight() {
        view.layoutIfNeeded()
        tableViewHeight.constant = tableView.contentSize.height
    }
    
    // MARK: - Active Duration Changed
    
    func sliderChanged(sliderActiveDuration: Int, forced: Bool) {
        activeDuration = sliderActiveDuration
        
        if activeDuration != 0 {
            if !mostActiveInProgress || forced {
                plots["Active"] = nil
                self.plots["Active"]?.plot = nil
                self.plots["Active"]?.data.removeAll()
                
                showMostActive = true
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    () -> Void in
                    self.findMostActive()
                })
            }
        } else {
            removeActivePlot()
            showMostActive = false
        }
    }
    
    func findMostActive() {
        if !mostActiveInProgress && bpm != nil && bpm.count > 0 {
            mostActiveInProgress = true
            GraphMostActive().mostActivePeriod(self.bpm, times: self.time, duration: Double(activeDuration), completion: {
                (timeOne, timeTwo) -> Void in
                
                let activeData = self.plotDataCreator.createMostActivePlotData(timeOne, end: timeTwo, max: self.plotMax, min: self.plotMin)
                let activePlot = GraphPlotSetup().createMostActivePlot(self.plotMin)
                
                self.plots["Active"] = ApercuPlot(plot: activePlot, data: activeData)
                
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    self.removeActivePlot()
                    
                    self.graph.addPlot(activePlot)
                    activePlot.dataSource = self
                    self.graph.reloadData()
                    //                self.removeAllPlots()
                    //
                    //                if self.segment.selectedSegmentIndex == 0 {
                    //                    self.addPlotsForNormalView()
                    //                } else {
                    //                    self.addPlotsForHeatmap(true, highPriority: true)
                    //                }
                    //
                    self.mostActiveInProgress = false
                })
            })
        }
    }
    
    // MARK: - On rotate
    
    func screenRotated(sender: AnyObject) {
        self.activeView.setNeedsDisplay()
        view.setNeedsDisplay()
    }
    
    
    // MARK: - Core Data Related Updaters
    
    func setTitle() {
        if currentWorkout.workout?.title != nil {
            title = currentWorkout.workout?.title
            setToText(titleTextView)
        } else {
            title = stringFromDate(currentWorkout.getStartDate()!)
            setToPlaceholder(titleTextView)
        }
    }
    
    func setDescriptionTextView() {
        if currentWorkout.workout?.desc != nil && currentWorkout.workout?.desc != "" {
            setToText(descTextView)
        } else {
            setToPlaceholder(descTextView)
        }
    }
    
    // Mark: - Text View
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        showToolbar(textView)
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if isPlaceHolder(textView) {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if !isPlaceHolder(textView) && textView.text != "" {
            if textView == titleTextView {
                coreDataHelper.updateTitle(textView.text, startDate: currentWorkout.getStartDate()!, endDate: currentWorkout.getEndDate()!)
            } else {
                coreDataHelper.updateTextDescription(textView.text, startDate: currentWorkout.getStartDate()!, endDate: currentWorkout.getEndDate()!)
            }
        }
        
        if textView.text == "" {
            setToPlaceholder(textView)
        }
    }
    
    func setToPlaceholder(textView: UITextView) {
        if textView == titleTextView {
            titleTextView.text = titlePlaceHolder
        } else {
            descTextView.text = descPlaceHolder
        }
        textView.textColor = UIColor.lightGrayColor()
        updateTextViewHeight(textView)
    }
    
    func setToText(textView: UITextView) {
        if textView == titleTextView {
            titleTextView.text = currentWorkout.workout?.title
        } else {
            descTextView.text = currentWorkout.workout?.desc
        }
        textView.textColor = UIColor.blackColor()
        updateTextViewHeight(textView)
    }
    
    func isPlaceHolder(textView: UITextView) -> Bool {
        if textView == titleTextView {
            return textView.text == titlePlaceHolder
        } else {
            return textView.text == descPlaceHolder
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        updateTextViewHeight(textView)
    }
    
    func updateTextViewHeight(textView: UITextView) {
        let width = textView.frame.width
        let newSize = textView.sizeThatFits(CGSizeMake(width, CGFloat.max))
        
        if textView == descTextView {
            descTextViewHeight.constant = newSize.height
        } else {
            titleTextViewHeight.constant = newSize.height
        }
    }
    
    // Mark: - Toolbar
    
    func showToolbar(sender: UITextView) {
            if keyboardToolbar == nil {
                keyboardToolbar = UIToolbar()
                keyboardToolbar.sizeToFit()
                nextBarButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(WorkoutDetailViewController.nextPressed(_:)))
                let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
                let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(WorkoutDetailViewController.hideKeyboard(_:)))
                
                keyboardToolbar.setItems([nextBarButton, spacer, doneButton], animated: false)
                keyboardToolbar.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
                keyboardToolbar.tintColor = UIColor.redColor()
            }
            
            if sender == titleTextView {
                titleTextView.inputAccessoryView = keyboardToolbar
            } else {
                descTextView.inputAccessoryView = keyboardToolbar
            }
    }
    
    func nextPressed(sender: UIBarButtonItem) {
        if titleTextView.isFirstResponder() {
            nextBarButton.title = "Prev"
            descTextView.becomeFirstResponder()
        } else {
            nextBarButton.title = "Next"
            titleTextView.becomeFirstResponder()
        }
    }
    
    func hideKeyboard(sender: AnyObject) {
        if descTextView.isFirstResponder() {
            descTextView.resignFirstResponder()
        } else {
            titleTextView.resignFirstResponder()
        }
        
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = edgeInsets
        scrollView.scrollIndicatorInsets = edgeInsets
        
                if allWorkouts != nil && allWorkouts.count > 1 {
        navigationController?.toolbarHidden = false
        }
    }
    
    func showKeyboard(sender: NSNotification) {
        navigationController?.toolbarHidden = true
        
        let info = sender.userInfo
        let keyboardDict = info![UIKeyboardFrameBeginUserInfoKey] as? NSValue
        let keyboardSize = keyboardDict?.CGRectValue()
        
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize!.size.height, right: 0)
        scrollView.contentInset = edgeInsets
        scrollView.scrollIndicatorInsets = edgeInsets
        
        let bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toCategorizeView" {
            let destination = segue.destinationViewController as? CategorizeWorkoutViewController
            destination?.workoutStart = currentWorkout.getStartDate()
            destination?.workoutEnd = currentWorkout.getEndDate()
            destination?.selectedCategory = currentWorkout.workout?.category
        }
    }
    
    // MARK: - Comparison Functions
    
    @IBAction func nextToolbarPressed(sender: AnyObject) {
        //        if !loadingHeatmap && !loadingStrings {
        mostActiveInProgress = false
        if currentWorkoutIndex == allWorkouts.count - 1 {
            currentWorkoutIndex = 0
        } else {
            currentWorkoutIndex += 1
        }
        updateComparisonLabels()
        loadWorkout()
        processCurrentWorkout(currentWorkoutIndex)
        //        }
    }
    
    @IBAction func previousToolbarPressed(sender: AnyObject) {
        //        if !loadingHeatmap && !loadingStrings {
        mostActiveInProgress = false
        if currentWorkoutIndex == 0 {
            currentWorkoutIndex = allWorkouts.count - 1
        } else {
            currentWorkoutIndex -= 1
        }
        
        updateComparisonLabels()
        loadWorkout()
        processCurrentWorkout(currentWorkoutIndex)
        //        }
    }
    
    func updateComparisonLabels() {
        centerToolbarButton.title = String(format: "%i / %i", currentWorkoutIndex + 1, allWorkouts.count)
    }
    
    
}