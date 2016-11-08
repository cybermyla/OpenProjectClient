//
//  MenuItemSideMenuTableViewCell.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 08/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class MenuItemSideMenuTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if (selected) {
            self.tintColor = UIColor.white
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }

}
