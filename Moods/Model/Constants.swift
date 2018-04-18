//
//  Constants.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import Foundation
import UIKit
class Constants{
    
    static let FORM_PAGINATION:Int = 10
    static let MOODS_URL:String = "http://apimoods.nicepeopleconsulting.com/v1/api";
    static let LOGIN_URL:String! = MOODS_URL + "/in";
    static let GET_PARAMS_URL:String = MOODS_URL + "/load";
    static let FORGOT_PASSWORD_URL:String = MOODS_URL + "/pasreco";
    static let GET_EVENTS_URL:String = MOODS_URL + "/mood/eventos";
    static let SEND_MOOD_URL:String = MOODS_URL + "/mood/";
    static let GET_CAMPAIGN_URL:String = MOODS_URL + "/campana/user";
    static let GET_FORMS_URL:String = MOODS_URL + "/usuario/todasencuestas";
    static let GET_QUESTIONS_URL:String = MOODS_URL + "/usuario/encuesta";
    static let SEND_FORM_URL:String = MOODS_URL + "/usuario/answer";
    static let GET_STATS_URL:String = MOODS_URL + "/team/stats";
    static let GET_BARS_URL:String = MOODS_URL + "/team/barstats";
    
    private var _phrases = [String]()
    var phrases:[String] {
        get {
            return _phrases
        }
        set {
            _phrases = newValue
        }
    }
    
    init() {
        fillPhrases()
    }
    /* */
    func fillPhrases(){
        _phrases.append("¡Juntos construimos el mejor lugar para trabajar!")
        _phrases.append("¡Con tus acciones creas experiencias, generas emociones y construyes equipo!")
        _phrases.append("“No somos un equipo porque trabajamos juntos. Somos un equipo porque respetamos, confiamos y nos preocupamos por el resto del equipo.”\n- Vala Afshar")
        _phrases.append("“Si podéis reír juntos, podéis trabajar juntos.”\n- Robert Orben")
    }
    /* */
    func getRandomPhrase()->String{
        let randomNum:UInt32 = arc4random_uniform(UInt32(_phrases.count))
        return _phrases[Int(randomNum)]
    }
    /* */
    func formatDate(date:Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    /* */
    func numberOfWeekssInMonth(date:Date) -> Int? {
        let calendar = NSCalendar.current
        let weekRange = calendar.range(of: .weekOfYear, in: .month, for: date)
        return weekRange?.count
    }
    /* */
    func getDatesOfAWeek(date:Date,laboralDays:String) -> [String] {
        var datesOfWeek = [String]()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        let dayOfWeek = calendar.component(.weekday, from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        let days = (weekdays.lowerBound ..< weekdays.upperBound)
            .flatMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today) }
        for dateTo in days {
            //Verify if is in the same month
            let formatter = DateFormatter()
            formatter.dateFormat = "MM"
            if(formatter.string(from: dateTo)==formatter.string(from: date)){
                //Verify if is a laboral day
                if(isDayInParams(day: getDayOfWeek(date: dateTo), laboralDays: laboralDays)){
                    datesOfWeek.append(formatDate(date: dateTo))
                }
            }
        }
        return datesOfWeek
    }
    
    /* */
    func getDatesOfAMonth(date:Date,laboralDays:String) -> [String] {
        var datesOfWeek = [String]()
        var startDate = startOfMonth(date: date)
        let endDate = endOfMonth(date: startDate)
        while startDate.compare(endDate) == .orderedAscending {
            datesOfWeek.append(formatDate(date: startDate))
            startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        }
        return datesOfWeek
    }
    
    /* */
    func startOfMonth(date:Date) -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from:date))!
    }
    /* */
    func endOfMonth(date:Date) -> Date {
        var cal = Calendar.current
        var comps = DateComponents()
        comps.month = 1
        comps.day = -1
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: date)!
    }
    
    /* */
    func getDatesOfAWeekDateFormat(date:Date,laboralDays:String) -> [Date] {
        var datesOfWeek = [Date]()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        let dayOfWeek = calendar.component(.weekday, from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        let days = (weekdays.lowerBound ..< weekdays.upperBound)
            .flatMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today) }
        for dateTo in days {
            //Verify if is in the same month
            let formatter = DateFormatter()
            formatter.dateFormat = "MM"
            if(formatter.string(from: dateTo)==formatter.string(from: date)){
                //Verify if is a laboral day
                if(isDayInParams(day: getDayOfWeek(date: dateTo), laboralDays: laboralDays)){
                    datesOfWeek.append(dateTo)
                }
            }
        }
        return datesOfWeek
    }
    /* */
    func getDayOfWeek(date:Date)->Int {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: date)
        return weekDay
    }
    /* */
    func isDayInParams(day:Int,laboralDays:String)->Bool{
        var isDay = false
        var stringArr:[String] = laboralDays.components(separatedBy: "_")
        for i in 0..<stringArr.count {
            let dayStr = stringArr[i]
            if(day==1 && dayStr=="D"){
                isDay = true
                break
            }else if(day==2 && dayStr=="L"){
                isDay = true
                break
            }else if(day==3 && dayStr=="Ma"){
                isDay = true
                break
            }else if(day==4 && dayStr=="Mi"){
                isDay = true
                break
            }else if(day==5 && dayStr=="J"){
                isDay = true
                break
            }else if(day==6 && dayStr=="V"){
                isDay = true
                break
            }else if(day==7 && dayStr=="S"){
                isDay = true
                break
            }
        }
        return isDay
    }
    
    /* */
    func getArrayOfDaysOfWeek(array:[Date])->[Int]{
        var days = [Int]()
        for i in 0..<array.count{
            let dayOfWeek = getDayOfWeek(date: array[i])
            days.append(dayOfWeek)
        }
        return days
    }
    
    /* */
    func isDayOfWeekInArray(array:[Int],day:Int)->Bool{
        var isHere = false
        for i in 0..<array.count{
            if(array[i]==day){
                isHere = true
                break
            }
        }
        return isHere
    }
    
    /* */
    func getImageOfProm(average:Double)->UIImage{
        if(average>=0 && average<2){
            return #imageLiteral(resourceName: "mood_angry")
        }else if(average>=2 && average<3){
            return #imageLiteral(resourceName: "mood_sad")
        }else if(average>=3 && average<4){
            return #imageLiteral(resourceName: "mood_5")
        }else if(average>=4 && average<4.8){
            return #imageLiteral(resourceName: "mood_normal")
        }else{
            return #imageLiteral(resourceName: "mood_happy")
        }
    }
    /* */
    func calculateAverage(numbers:[Double],total:Double)->Double{
        var average = 0.0
        for i in 0..<numbers.count{
            let number = numbers[i]
            average = average + number
        }
        if(total>0.0){
            average = average/total
        }else{
            average = 0
        }
        return average
    }
    /* */
    func dayRangeOf(weekOfMonth: Int, year: Int, month: Int) -> [Date]? {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: DateComponents(year:year, month:month)) else { return nil }
        var startDate = Date()
        if weekOfMonth == 1 {
            var interval = TimeInterval()
            guard calendar.dateInterval(of: .weekOfMonth, start: &startDate, interval: &interval, for: startOfMonth) else { return nil }
        } else {
            let nextComponents = DateComponents(year: year, month: month, weekOfMonth: weekOfMonth)
            guard let weekStartDate = calendar.nextDate(after: startOfMonth, matching: nextComponents, matchingPolicy: .nextTime) else {
                return nil
            }
            startDate = weekStartDate
        }
        let endComponents = DateComponents(day:7, second: -1)
        let endDate = calendar.date(byAdding: endComponents, to: startDate)!
        
        var array = [Date]()
        while(startDate.compare(endDate) == .orderedAscending){
            array.append(startDate)
            startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        }
        
        return array
    }
    
}

