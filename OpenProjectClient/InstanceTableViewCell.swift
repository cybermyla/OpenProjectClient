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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.selectionStyle = .none

        if (selected) {
            let colorView = UIView()
            colorView.backgroundColor = UIColor.clear
            self.selectedBackgroundView = colorView
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }
}
