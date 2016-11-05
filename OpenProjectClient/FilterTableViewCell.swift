//
//  FilterTableViewCell.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelPriority: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        if (selected) {            
            self.tintColor = Colors.darkAzureOP.getUIColor()
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }

}
