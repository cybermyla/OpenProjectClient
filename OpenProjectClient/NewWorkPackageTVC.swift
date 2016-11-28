//
//  NewWorkPackageTableViewCell.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 27/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class NewWorkPackageTVC: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var value: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
