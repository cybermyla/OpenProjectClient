//
//  FilterDetailTableViewCell.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 23/10/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class FilterDetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.selectionStyle = .none
        
        if (selected) {
            self.tintColor = Colors.darkAzureOP.getUIColor()
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }

}
