//
//  QuestionTableViewCell.swift
//  Moods
//
//  Created by Santiago Moreno on 9/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var btnOption1: UIButton!
    @IBOutlet weak var btnOption2: UIButton!
    @IBOutlet weak var btnOption3: UIButton!
    @IBOutlet weak var btnOption4: UIButton!
    @IBOutlet weak var btnOption5: UIButton!
    
    var question:FormQuestion!
    var options = [FormOption]()
    var indexQuestion:Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
     Actions
     **/
    
    @IBAction func option1Selected(_ sender: Any) {
        clearSelection()
        btnOption1.setTitleColor(UIColor(red:0.05, green:0.45, blue:0.95, alpha:1.0), for: .normal)
        options[0].checked = true
        question.selectedOption = options[0]
    }
    @IBAction func option2Selected(_ sender: Any) {
        clearSelection()
        btnOption2.setTitleColor(UIColor(red:0.05, green:0.45, blue:0.95, alpha:1.0), for: .normal)
        options[1].checked = true
        question.selectedOption = options[1]
    }
    @IBAction func option3Selected(_ sender: Any) {
        clearSelection()
        btnOption3.setTitleColor(UIColor(red:0.05, green:0.45, blue:0.95, alpha:1.0), for: .normal)
        options[2].checked = true
        question.selectedOption = options[2]
    }
    @IBAction func option4Selected(_ sender: Any) {
        clearSelection()
        btnOption4.setTitleColor(UIColor(red:0.05, green:0.45, blue:0.95, alpha:1.0), for: .normal)
        options[3].checked = true
        question.selectedOption = options[3]
    }
    @IBAction func option5Selected(_ sender: Any) {
        clearSelection()
        btnOption5.setTitleColor(UIColor(red:0.05, green:0.45, blue:0.95, alpha:1.0), for: .normal)
        options[4].checked = true
        question.selectedOption = options[4]
    }
    /*
     Clear the preview selection
     */
    func clearSelection(){
        btnOption1.setTitleColor(UIColor(red:0.59, green:0.59, blue:0.59, alpha:1.0), for: .normal)
        btnOption2.setTitleColor(UIColor(red:0.59, green:0.59, blue:0.59, alpha:1.0), for: .normal)
        btnOption3.setTitleColor(UIColor(red:0.59, green:0.59, blue:0.59, alpha:1.0), for: .normal)
        btnOption4.setTitleColor(UIColor(red:0.59, green:0.59, blue:0.59, alpha:1.0), for: .normal)
        btnOption5.setTitleColor(UIColor(red:0.59, green:0.59, blue:0.59, alpha:1.0), for: .normal)
    }
    
}
