//
//  ProjectItemSideMenuTableViewCell.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 17/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class ProjectItemSideMenuTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.backgroundColor = Colors.lightAzureOP.getUIColor()
        // Configure the view for the selected state
        if (selected) {
            self.backgroundColor = UIColor.clear
        } else {
            self.backgroundColor = UIColor.clear
        }
    }

}
