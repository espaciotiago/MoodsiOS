//
//  FormTableViewCell.swift
//  Moods
//
//  Created by Santiago Moreno on 8/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit

class FormTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var labelNameForm: UILabel!
    @IBOutlet weak var labelTotalQuestions: UILabel!
    @IBOutlet weak var labelCloseDate: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
