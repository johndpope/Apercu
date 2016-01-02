//
//  CustomScrollView.swift
//  Apercu
//
//  Created by David Lantrip on 1/1/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import UIKit
import CorePlot

class CustomScrollView: UIScrollView {
    
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        
        if view.isKindOfClass(CPTGraphHostingView) {
            return false
        } else if view.isKindOfClass(UISegmentedControl){
            return true
        } else if view.isKindOfClass(UISwitch) {
            return true
        } else if view.isKindOfClass(UIButton) {
            return true
        }
        
        return super.touchesShouldCancelInContentView(view)
    }
    
}