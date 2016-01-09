//
//  StatCell.swift
//  Apercu
//
//  Created by David Lantrip on 1/5/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import UIKit

class StatCell: UITableViewCell {
    
    @IBOutlet var topRightLabel: UILabel!
    @IBOutlet var topLeftLabel: UILabel!
    @IBOutlet var bottomRightLabel: UILabel!
    @IBOutlet var bottomLeftLabel: UILabel!
    
    @IBOutlet var bottomRightHeight: NSLayoutConstraint!
    @IBOutlet var bottomLeftHeight: NSLayoutConstraint!
    @IBOutlet var bottomPadding: NSLayoutConstraint!
    
}