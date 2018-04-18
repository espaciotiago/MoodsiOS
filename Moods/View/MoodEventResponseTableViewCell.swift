//
//  EventBarTableViewCell.swift
//  Moods
//
//  Created by Santiago Moreno on 5/02/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import Charts

class MoodEventResponseTableViewCell: UITableViewCell, ChartViewDelegate {
    
    @IBOutlet weak var selectedEvent: UILabel!
    @IBOutlet weak var titleMood: UILabel!
    @IBOutlet weak var imgMood: UIImageView!
    @IBOutlet weak var barChart: BarChartView!
    var labels = [String]()

    override func awakeFromNib() {
        self.barChart.delegate = self
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        selectedEvent.text = ""
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let selectedPos = Int(entry.x)
        let value = labels[selectedPos]
        selectedEvent.text = value
    }

}
