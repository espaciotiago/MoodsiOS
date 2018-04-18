//
//  TeamWeekViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import Charts
import CoreData
import Alamofire

class TeamWeekViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    @IBOutlet weak var timelineLineChartView: LineChartView!
    @IBOutlet weak var btnD: UIButton!
    @IBOutlet weak var btnL: UIButton!
    @IBOutlet weak var btnM: UIButton!
    @IBOutlet weak var btnX: UIButton!
    @IBOutlet weak var btnJ: UIButton!
    @IBOutlet weak var btnV: UIButton!
    @IBOutlet weak var btnS: UIButton!
    @IBOutlet weak var dropdownListTeams: UIPickerView!
    @IBOutlet weak var textViewSelectTeam: UITextField!
    @IBOutlet weak var txtTotalResp: UILabel!
    @IBOutlet weak var txtPromedio: UILabel!
    @IBOutlet weak var txtDesviacion: UILabel!
    
    @IBOutlet weak var imgPromedio: UIImageView!
    
    var months = [String]()
    var moodsInfo:[Double] = []
    var currentDate:Date = Date()
    var datesOfWeek = [String]()
    var datesOfWeekDateFormat = [Date]()
    var datesOfWeekInt = [Int]()
    var selectedDate:Date = Date()
    var controller:NSFetchedResultsController<UsserSession>!
    var controllerTeams:NSFetchedResultsController<Team>!
    var controllerParams:NSFetchedResultsController<Params>!
    var errorMessage = ""
    var userId = ""
    var teamId = ""
    var laboralDays = ""
    var teamsIds = [String]()
    var teamsNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd"
        //currentDate = formatter.date(from: "2018/01/31")!
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
        
        datesOfWeek = Constants().getDatesOfAWeek(date: currentDate, laboralDays: laboralDays)
        datesOfWeekDateFormat = Constants().getDatesOfAWeekDateFormat(date: currentDate, laboralDays: laboralDays)
        datesOfWeekInt = Constants().getArrayOfDaysOfWeek(array: datesOfWeekDateFormat)
        //Set the labels of the charts - Set the display days of week
        btnD.isHidden = true
        btnL.isHidden = true
        btnM.isHidden = true
        btnX.isHidden = true
        btnJ.isHidden = true
        btnV.isHidden = true
        btnS.isHidden = true
        if(Constants().isDayInParams(day: 1, laboralDays: laboralDays) && Constants().isDayOfWeekInArray(array: datesOfWeekInt, day: 1)){
            months.append("D")
            btnD.isHidden = false
        }
        if(Constants().isDayInParams(day: 2, laboralDays: laboralDays) && Constants().isDayOfWeekInArray(array: datesOfWeekInt, day: 2)){
            months.append("L")
            btnL.isHidden = false
        }
        if(Constants().isDayInParams(day: 3, laboralDays: laboralDays) && Constants().isDayOfWeekInArray(array: datesOfWeekInt, day: 3)){
            months.append("M")
            btnM.isHidden = false
        }
        if(Constants().isDayInParams(day: 4, laboralDays: laboralDays) && Constants().isDayOfWeekInArray(array: datesOfWeekInt, day: 4)){
            months.append("X")
            btnX.isHidden = false
        }
        if(Constants().isDayInParams(day: 5, laboralDays: laboralDays) && Constants().isDayOfWeekInArray(array: datesOfWeekInt, day: 5)){
            months.append("J")
            btnJ.isHidden = false
        }
        if(Constants().isDayInParams(day: 6, laboralDays: laboralDays) && Constants().isDayOfWeekInArray(array: datesOfWeekInt, day: 6)){
            months.append("V")
            btnV.isHidden = false
        }
        if(Constants().isDayInParams(day: 7, laboralDays: laboralDays) && Constants().isDayOfWeekInArray(array: datesOfWeekInt, day: 7)){
            months.append("S")
            btnS.isHidden = false
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
    /*
     Load the week data from the server
     */
    func loadData(){
        moodsInfo = []
        let weeksDates = Constants().getDatesOfAWeek(date: self.currentDate, laboralDays: self.laboralDays)
        var weekDictionary = [Dictionary<String,String>]()
        for i in 0..<weeksDates.count{
            let date = weeksDates[i]
            var dateDictionary = Dictionary<String,String>()
            dateDictionary.updateValue(date, forKey: "dia")
            weekDictionary.append(dateDictionary)
        }
        
        //Create the JSON to send
        let parameters: Parameters = [
            "idusuario": userId,
            "idequipo": teamId,
            "fecha": Constants().formatDate(date: currentDate),
            "indicador": "S",
            "dias_semana": weekDictionary
        ]
        print("Params: \(parameters)")
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
                                        print("Body: \(body)")
                                        var desviacion_promedio = 0.0
                                        var promedio = 0.0
                                        var total_respuestas_enviadas = 0.0
                                        let total_respuestas_esperadas = 0.0
                                        let dias_semana = body?.object(forKey: "dias_semana") as? NSArray
                                        
                                        if(body?.object(forKey: "promedio") as? Double != nil){
                                            let x = body?.object(forKey: "promedio") as? Double
                                            promedio = Double(round(1000 * x!/1000))
                                        }
                                        if(body?.object(forKey: "desviacion_promedio") as? Double != nil){
                                            let x = body?.object(forKey: "desviacion_promedio") as? Double
                                            desviacion_promedio = Double(round(1000 * x!/1000))
                                        }
                                        if(body?.object(forKey: "total_respuestas_enviadas") as? Double != nil){
                                            let x = body?.object(forKey: "total_respuestas_enviadas") as? Double
                                            total_respuestas_enviadas = Double(round(1000 * x!/1000))
                                        }
                                        self.imgPromedio.image = Constants().getImageOfProm(average: promedio)
                                        self.txtPromedio.text = "\(promedio)"
                                        self.txtDesviacion.text = "\(desviacion_promedio)"
                                        self.txtTotalResp.text = "\(total_respuestas_enviadas)"
                                        
                                        if(dias_semana != nil){
                                            for i in 0..<dias_semana!.count{
                                                let dia = dias_semana![i] as? NSDictionary
                                                if(dia != nil){
                                                    print("Dia: \(dia)")
                                                    let promedio = dia?.object(forKey: "promedio") as? String
                                                    if(promedio != nil && !(promedio?.isEmpty)!){
                                                        let promDouble = Double(promedio!)
                                                        self.moodsInfo.append(promDouble!)
                                                    }else{
                                                        let promDouble = 0.0
                                                        self.moodsInfo.append(promDouble)
                                                    }
                                                    
                                                }
                                            }
                                            self.setChartData(dataPoints: self.months, values: self.moodsInfo)
                                        }
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
     Prepare the segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? TeamDayViewController {
            viewControllerB.currentDate = self.selectedDate
        }
    }
    
    /* -----------------------------------------------------------------------------
     Actions - weekToDaySegue
     ----------------------------------------------------------------------------- */
    @IBAction func onClickD(_ sender: Any) {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: currentDate)
        comps.weekday = 1
        selectedDate = calendar.date(from: comps)!
        performSegue(withIdentifier: "weekToDaySegue", sender: self)
    }
    @IBAction func onClickL(_ sender: Any) {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: currentDate)
        comps.weekday = 2
        selectedDate = calendar.date(from: comps)!
        performSegue(withIdentifier: "weekToDaySegue", sender: self)
    }
    @IBAction func onClickM(_ sender: Any) {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: currentDate)
        comps.weekday = 3
        selectedDate = calendar.date(from: comps)!
        performSegue(withIdentifier: "weekToDaySegue", sender: self)
    }
    @IBAction func onClickX(_ sender: Any) {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: currentDate)
        comps.weekday = 4
        selectedDate = calendar.date(from: comps)!
        performSegue(withIdentifier: "weekToDaySegue", sender: self)
    }
    @IBAction func onClickJ(_ sender: Any) {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: currentDate)
        comps.weekday = 5
        selectedDate = calendar.date(from: comps)!
        performSegue(withIdentifier: "weekToDaySegue", sender: self)
    }
    @IBAction func onClickV(_ sender: Any) {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: currentDate)
        comps.weekday = 6
        selectedDate = calendar.date(from: comps)!
        performSegue(withIdentifier: "weekToDaySegue", sender: self)
    }
    @IBAction func onClickS(_ sender: Any) {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: currentDate)
        comps.weekday = 7
        selectedDate = calendar.date(from: comps)!
        performSegue(withIdentifier: "weekToDaySegue", sender: self)
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
        moodsInfo = []
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
