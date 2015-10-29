//
//  InstanceTableViewCell.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 28/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class InstanceTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.selectionStyle = .None

        if (selected) {
            let colorView = UIView()
            colorView.backgroundColor = UIColor.clearColor()
            self.selectedBackgroundView = colorView
            self.accessoryType = .Checkmark
        } else {
            self.accessoryType = .None
        }
    }
}
