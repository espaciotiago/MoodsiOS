//
//  EventTableViewCell.swift
//  Moods
//
//  Created by Santiago Moreno on 8/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var labelEvent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
