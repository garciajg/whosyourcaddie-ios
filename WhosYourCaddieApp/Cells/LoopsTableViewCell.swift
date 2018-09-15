//
//  LoopsTableViewCell.swift
//  WhosYourCaddieApp
//
//  Created by Jose Garcia on 9/10/18.
//  Copyright © 2018 Jose Garcia. All rights reserved.
//

import UIKit

class LoopsTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var numberOfHolesLabel: UILabel!
    @IBOutlet weak var walkingLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
