//
//  LineChartFormatter.swift
//  Moods
//
//  Created by Santiago Moreno on 7/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//
import UIKit
import Foundation
import Charts

@objc(BarChartFormatter)
public class LineChartFormatter: NSObject, IAxisValueFormatter{
    
    var months: [String]! = []
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        return months[Int(value)]
    }
}
