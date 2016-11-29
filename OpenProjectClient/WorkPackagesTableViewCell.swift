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
        labelSubject.font = UIFont.boldSystemFont(ofSize: 18.0)
        labelSubject.textColor = Colors.darkAzureOP.getUIColor()
        labelDescription.textColor = UIColor.darkGray
        labelDescription.font = UIFont.systemFont(ofSize: 13.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
