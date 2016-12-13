//
//  AddWatcherTVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 13/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class AddWatcherTVC: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if (selected) {
            let colorView = UIView()
            colorView.backgroundColor = UIColor.clear
            self.selectedBackgroundView = colorView
            
            self.tintColor = Colors.darkAzureOP.getUIColor()
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }

}
