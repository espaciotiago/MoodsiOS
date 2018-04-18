//
//  TeamMonthViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import Charts
import CoreData
import Alamofire

class TeamMonthViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    
    @IBOutlet weak var timelineLineChartView: LineChartView!
    @IBOutlet weak var btnS1: UIButton!
    @IBOutlet weak var btnS2: UIButton!
    @IBOutlet weak var btnS3: UIButton!
    @IBOutlet weak var btnS4: UIButton!
    @IBOutlet weak var btnS5: UIButton!
    @IBOutlet weak var btnS6: UIButton!
    @IBOutlet weak var dropdownListTeams: UIPickerView!
    @IBOutlet weak var textViewSelectTeam: UITextField!
    @IBOutlet weak var imgPromedio: UIImageView!
    @IBOutlet weak var txtTotalResp: UILabel!
    @IBOutlet weak var txtDesviacion: UILabel!
    @IBOutlet weak var txtPromedio: UILabel!
    
    var controller:NSFetchedResultsController<UsserSession>!
    var controllerTeams:NSFetchedResultsController<Team>!
    var controllerParams:NSFetchedResultsController<Params>!
    
    var weeksOfMonth = [String]()
    var moodsInfo:[Double] = []
    var currentDate = Date()
    var errorMessage = ""
    var userId = ""
    var teamId = ""
    var laboralDays = ""
    var teamsIds = [String]()
    var teamsNames = [String]()
    var selectedDate = Date()
    var totalWeeks = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd"
        //currentDate = formatter.date(from: "2017/12/20")!
        attemptFetch()
        attemptFetchTeams()
        attemptFetchParams()
        //Get the id of the loged user
        var howManyUsers = 0
        if let sections = controller.sections {
            let sectionInfo = sections[0]
            howManyUsers = sectionInfo.numberOfObjects
            if(howManyUsers > 0){
                let userLoged = sectionInfo.objects![0] as! UsserSession
                self.userId = userLoged.id_server!
            }
        }
        
        //Get the id of the first (default) team
        var howManyTeams = 0
        if let sections = controllerTeams.sections {
            let sectionInfo = sections[0]
            howManyTeams = sectionInfo.numberOfObjects
            if(howManyTeams > 0){
                let team = sectionInfo.objects![0] as! Team
                self.teamId = team.team_id!
                self.textViewSelectTeam.text = team.name!
            }
        }
        
        //Get the laboral das of the params
        var howManyParams = 0
        if let sections = controllerParams.sections {
            let sectionInfo = sections[0]
            howManyParams = sectionInfo.numberOfObjects
            if(howManyParams > 0){
                let params = sectionInfo.objects![0] as! Params
                laboralDays = params.laboral_days!
            }
        }
        
        //Set the labels
        totalWeeks = Constants().numberOfWeekssInMonth(date: currentDate)!
        for i in 0..<totalWeeks {
            weeksOfMonth.append("S\(i+1)")
        }
        if(totalWeeks<6){
            btnS6.isHidden = true
        }
        if(totalWeeks<5){
            btnS5.isHidden = true
        }
        if(totalWeeks<4){
            btnS4.isHidden = true
        }
        if(totalWeeks<3){
            btnS3.isHidden = true
        }
        if(totalWeeks<2){
            btnS2.isHidden = true
        }
        if(totalWeeks<1){
            btnS1.isHidden = true
        }
        
        //Prepare the team selector options
        textViewSelectTeam.inputView = UIView();
        createListOfTeams()
        dropdownListTeams.isHidden = true
        textViewSelectTeam.addTarget(self, action:  #selector(myTargetFunction), for: .touchDown)
        dropdownListTeams.reloadAllComponents()
        //Load the data and create the charts info
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     Create the list of teams
     */
    func createListOfTeams(){
        //Get the teams
        var howManyTeams = 0
        if let sections = controllerTeams.sections {
            let sectionInfo = sections[0]
            howManyTeams = sectionInfo.numberOfObjects
            if(howManyTeams > 0){
                for i in 0..<howManyTeams{
                    let team = sectionInfo.objects![i] as! Team
                    teamsIds.append(team.team_id!)
                    teamsNames.append(team.name!)
                }
            }
        }
    }
    
    /**
     Sets the data in the cart view
     **/
    func setChartData(dataPoints: [String], values: [Double]){
        //General Configurations of the linechart
        timelineLineChartView.noDataText = "No hay datos disponibles para la fecha"
        //Set the charts
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Moods")
        //Styling the charts
        lineChartDataSet.colors = [NSUIColor.blue]
        lineChartDataSet.circleColors = [NSUIColor.orange]
        lineChartDataSet.circleRadius = 4.0
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.fill = Fill.fillWithCGColor(UIColor(red: 0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor)
        lineChartDataSet.drawFilledEnabled = true
        //Set the data in the chart
        let lineChartData = LineChartData()
        lineChartData.setDrawValues(false)
        lineChartData.addDataSet(lineChartDataSet)
        //Axex setup
        let formato:LineChartFormatter = LineChartFormatter()
        formato.months = dataPoints
        let xaxis:XAxis = XAxis()
        for i in 0..<formato.months.count {
            formato.stringForValue(Double(i), axis: xaxis)
            xaxis.valueFormatter = formato
        }
        
        timelineLineChartView.xAxis.valueFormatter = formato
        //timelineLineChartView.leftAxis.axisMaximum = 4.5
        //timelineLineChartView.leftAxis.axisMinimum = 1
        timelineLineChartView.leftAxis.drawGridLinesEnabled = false
        timelineLineChartView.xAxis.drawGridLinesEnabled = false
        timelineLineChartView.xAxis.labelPosition = .bottom
        timelineLineChartView.rightAxis.drawGridLinesEnabled = false
        timelineLineChartView.rightAxis.drawLabelsEnabled = false
        timelineLineChartView.data = lineChartData
    }
    
    /*
     Load the week data from the server
     */
    func loadData(){
        moodsInfo = []
        var dictionary = [Dictionary<String, Any>]()
        for i in 0..<self.totalWeeks{
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year,.month], from: currentDate)
            let weeksDates = Constants().dayRangeOf(weekOfMonth: i+1, year: dateComponents.year!, month: dateComponents.month!)!
            var weekDictionary = [Dictionary<String,String>]()
            var dictionaryAditional = Dictionary<String, Any>()
            for j in 0..<weeksDates.count{
                let date = weeksDates[j]
                let selectedDateComponents = calendar.dateComponents([.year,.month], from: date)
                if(dateComponents.year! == selectedDateComponents.year! && dateComponents.month! == selectedDateComponents.month!){
                    var dateDictionary = Dictionary<String,String>()
                    dateDictionary.updateValue(Constants().formatDate(date: date), forKey: "dia")
                    weekDictionary.append(dateDictionary)
                }
            }
            dictionaryAditional.updateValue(i+1, forKey: "semana")
            dictionaryAditional.updateValue(weekDictionary, forKey: "dias_semana")
            dictionary.append(dictionaryAditional)
        }
        //Create the JSON to send
        let parameters: Parameters = [
            "idusuario": userId,
            "idequipo": teamId,
            "fecha": Constants().formatDate(date: currentDate),
            "indicador": "M",
            "semanas": dictionary
        ]
        print("params: \(parameters)")
        //Send info to the server and verify
        Alamofire.request(Constants.GET_STATS_URL,
                          method: .post,
                          parameters:parameters,
                          encoding: JSONEncoding.default).responseJSON { response in
                            
                            //Json response parse
                            if let json:NSDictionary = response.result.value as? NSDictionary {
                                //Get values from response
                                let ans:Int = json.object(forKey: "ans") as! Int
                                let body = json.object(forKey: "body") as? NSDictionary
                                self.errorMessage = json.object(forKey: "error") as! String
                                
                                if(ans == 1){
                                    //Get the Week chart data
                                    if(body != nil){
                                        var desviacionPromedio = body?.object(forKey: "desviacion_promedio") as? Double
                                        var desv = 0.0
                                        if desviacionPromedio != nil {
                                            desv = Double(round(1000*desviacionPromedio!)/1000)
                                            
                                        }
                                        self.txtDesviacion.text = "\(desv)"
                                        let semanas = body?.object(forKey: "semanas") as? NSArray
                                        if(semanas != nil){
                                            var totalPromedio = 0.0
                                            var totalEnv = 0.0
                                            for i in 0..<semanas!.count{
                                                let semana = semanas![i] as? NSDictionary
                                                if(semana != nil){
                                                    print("Semana: \(semana)")
                                                    let promedio = semana!.object(forKey: "promedio") as? Double
                                                    let total = semana!.object(forKey: "num_respuestas_enviadas") as? Double
                                                    var promedioDouble = 0.0
                                                    if(promedio != nil){
                                                        promedioDouble = promedio!
                                                    }
                                                    if(total != nil){
                                                        totalEnv = totalEnv + total!
                                                    }
                                                    totalPromedio = totalPromedio + promedioDouble
                                                    self.moodsInfo.append(promedioDouble)
                                                }
                                            }
                                            totalPromedio = totalPromedio/Double(semanas!.count)
                                            totalPromedio = Double(round(1000*totalPromedio)/1000)
                                            self.imgPromedio.image = Constants().getImageOfProm(average: totalPromedio)
                                            self.txtPromedio.text = "\(totalPromedio)"
                                            self.txtTotalResp.text = "\(totalEnv)"
                                        }
                                        self.setChartData(dataPoints: self.weeksOfMonth, values: self.moodsInfo)
                                    }
                                }else{ //Go to Error screen
                                    self.performSegue(withIdentifier: "ToErrorSegue", sender: self)
                                }
                            }else{ //Go to Error screen
                                //Algun error extraño - Conexión probablemente
                                self.errorMessage = "No se ha podido acceder al servidor, compruebe su conexión y vuelv aa intentar"
                                self.performSegue(withIdentifier: "ToErrorSegue", sender: self)
                            }
        }
    }
    
    /*
     Prepare the segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? TeamWeekViewController {
            viewControllerB.currentDate = self.selectedDate
        }
    }
    
    /* ----------------------------------------------------------------------------- */
     /* Actions: Click on bottom bar items - Week of month selection toWeekSegue */
    /* ----------------------------------------------------------------------------- */
    @IBAction func onClickS1(_ sender: Any) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year,.month], from: currentDate)
        let datesArray = Constants().dayRangeOf(weekOfMonth: 1, year: dateComponents.year!, month: dateComponents.month!)!
        for i in 0..<datesArray.count{
            let date = datesArray[i]
            let selectedDateComponents = calendar.dateComponents([.year,.month], from: date)
            if(dateComponents.year! == selectedDateComponents.year! && dateComponents.month! == selectedDateComponents.month!){
                selectedDate = date
                break
            }
        }
        performSegue(withIdentifier: "toWeekSegue", sender: self)
    }
    @IBAction func onCLickS2(_ sender: Any) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year,.month], from: currentDate)
        let datesArray = Constants().dayRangeOf(weekOfMonth: 2, year: dateComponents.year!, month: dateComponents.month!)!
        for i in 0..<datesArray.count{
            let date = datesArray[i]
            let selectedDateComponents = calendar.dateComponents([.year,.month], from: date)
            if(dateComponents.year! == selectedDateComponents.year! && dateComponents.month! == selectedDateComponents.month!){
                selectedDate = date
                break
            }
        }
        performSegue(withIdentifier: "toWeekSegue", sender: self)
    }
    @IBAction func onClickS3(_ sender: Any) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year,.month], from: currentDate)
        let datesArray = Constants().dayRangeOf(weekOfMonth: 3, year: dateComponents.year!, month: dateComponents.month!)!
        for i in 0..<datesArray.count{
            let date = datesArray[i]
            let selectedDateComponents = calendar.dateComponents([.year,.month], from: date)
            if(dateComponents.year! == selectedDateComponents.year! && dateComponents.month! == selectedDateComponents.month!){
                selectedDate = date
                break
            }
        }
        performSegue(withIdentifier: "toWeekSegue", sender: self)
    }
    @IBAction func onClickS4(_ sender: Any) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year,.month], from: currentDate)
        let datesArray = Constants().dayRangeOf(weekOfMonth: 4, year: dateComponents.year!, month: dateComponents.month!)!
        for i in 0..<datesArray.count{
            let date = datesArray[i]
            let selectedDateComponents = calendar.dateComponents([.year,.month], from: date)
            if(dateComponents.year! == selectedDateComponents.year! && dateComponents.month! == selectedDateComponents.month!){
                selectedDate = date
                break
            }
        }
        performSegue(withIdentifier: "toWeekSegue", sender: self)
    }
    @IBAction func onClickS5(_ sender: Any) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year,.month], from: currentDate)
        let datesArray = Constants().dayRangeOf(weekOfMonth: 5, year: dateComponents.year!, month: dateComponents.month!)!
        for i in 0..<datesArray.count{
            let date = datesArray[i]
            let selectedDateComponents = calendar.dateComponents([.year,.month], from: date)
            if(dateComponents.year! == selectedDateComponents.year! && dateComponents.month! == selectedDateComponents.month!){
                selectedDate = date
                break
            }
        }
        performSegue(withIdentifier: "toWeekSegue", sender: self)
    }
    @IBAction func onClickS6(_ sender: Any) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year,.month], from: currentDate)
        let datesArray = Constants().dayRangeOf(weekOfMonth: 6, year: dateComponents.year!, month: dateComponents.month!)!
        for i in 0..<datesArray.count{
            let date = datesArray[i]
            let selectedDateComponents = calendar.dateComponents([.year,.month], from: date)
            if(dateComponents.year! == selectedDateComponents.year! && dateComponents.month! == selectedDateComponents.month!){
                selectedDate = date
                break
            }
        }
        performSegue(withIdentifier: "toWeekSegue", sender: self)
    }
    /* ----------------------------------------------------------------------------- */
    /* UIPickerView stuff */
    /* ----------------------------------------------------------------------------- */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teamsIds.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teamsNames[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.teamId = teamsIds[row]
        self.textViewSelectTeam.text = teamsNames[row]
        //self.dropdownListTeams.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.dropdownListTeams.alpha = 0
        }) { (finished) in
            self.dropdownListTeams.isHidden = finished
        }
        loadData()
    }
    //When textfield is touched - Select team
    @objc func myTargetFunction(textField: UITextField) {
        // user touch field
        self.dropdownListTeams.alpha = 0
        self.dropdownListTeams.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.dropdownListTeams.alpha = 1
        }
    }
    /* ----------------------------------------------------------------------------- */
    /* CORE DATA METHODS */
    /* ----------------------------------------------------------------------------- */
    func attemptFetch(){
        let fetchRequest:NSFetchRequest<UsserSession> = UsserSession.fetchRequest()
        let defaultSort = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [defaultSort]
        
        controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do{
            try controller.performFetch()
        }catch{
            let error = error as NSError
            print("Error fetching: \(error)")
        }
    }
    func attemptFetchTeams(){
        let fetchRequest:NSFetchRequest<Team> = Team.fetchRequest()
        let defaultSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [defaultSort]
        
        controllerTeams = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do{
            try controllerTeams.performFetch()
        }catch{
            let error = error as NSError
            print("Error fetching: \(error)")
        }
    }
    func attemptFetchParams(){
        let fetchRequest:NSFetchRequest<Params> = Params.fetchRequest()
        let defaultSort = NSSortDescriptor(key: "start_hour", ascending: false)
        fetchRequest.sortDescriptors = [defaultSort]
        
        controllerParams = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do{
            try controllerParams.performFetch()
        }catch{
            let error = error as NSError
            print("Error fetching: \(error)")
        }
    }
}
