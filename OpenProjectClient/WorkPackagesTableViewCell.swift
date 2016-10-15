//
//  WorkPackagesTableViewCell.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 26/06/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class WorkPackagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelSubject: UILabel!
    @IBOutlet weak var labelDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
