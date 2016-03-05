//
//  tagCell.swift
//  Apercu
//
//  Created by David Lantrip on 10/8/15.
//  Copyright © 2015 David Lantrip. All rights reserved.
//

import Foundation
import UIKit

class TagCell: UICollectionViewCell {
    
    @IBOutlet var tagLabelWidth: NSLayoutConstraint!
    @IBOutlet var tagLabel: UILabel!
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        self.tagLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        self.layer.cornerRadius = 4
        
        self.tagLabelWidth.constant = UIScreen.mainScreen().bounds.width - 8 * 2 - 8 * 2
    }
}