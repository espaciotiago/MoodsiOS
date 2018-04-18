//
//  TimelineViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import Charts
import CoreData
import Alamofire

class TimelineViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    @IBOutlet weak var timelineChartView: LineChartView!
    @IBOutlet weak var textViewSelectTeam: UITextField!
    @IBOutlet weak var dropdownListTeams: UIPickerView!
    
    var months: [String]!
    var moodsInfo:[Double] = []
    var daysOfMonth = [String]()
    var currentDate:Date = Date()
    var controller:NSFetchedResultsController<UsserSession>!
    var controllerTeams:NSFetchedResultsController<Team>!
    var errorMessage = ""
    var userId = ""
    var teamId = ""
    var laboralDays = "L_Ma_Mi_J_V_S_D"
    var teamsIds = [String]()
    var teamsNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        //let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd"
        //currentDate = formatter.date(from: "2018-02-12")!
        attemptFetch()
        attemptFetchTeams()
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
        
        //Prepare the team selector options
        textViewSelectTeam.inputView = UIView();
        createListOfTeams()
        dropdownListTeams.isHidden = true
        //textViewSelectTeam.isEnabled = false
        textViewSelectTeam.addTarget(self, action:  #selector(myTargetFunction), for: .touchDown)
        dropdownListTeams.reloadAllComponents()
        
        //Get the days of the month and load the data from the server
        daysOfMonth = Constants().getDatesOfAMonth(date: currentDate, laboralDays: laboralDays)
        months = []
        moodsInfo = []
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
        let weeksDates = Constants().getDatesOfAMonth(date: self.currentDate, laboralDays: self.laboralDays)
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
                                        let desviacion_promedio = body?.object(forKey: "desviacion_promedio") as? String
                                        let promedio = body?.object(forKey: "promedio") as? String
                                        let total_respuestas_enviadas = body?.object(forKey: "total_respuestas_enviadas") as? String
                                        let total_respuestas_esperadas = body?.object(forKey: "total_respuestas_esperadas") as? String
                                        let dias_semana = body?.object(forKey: "dias_semana") as? NSArray
                                        
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
        timelineChartView.noDataText = "No hay datos disponibles para la fecha"
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
        //timelineChartView.leftAxis.axisMaximum = 4.5
        //timelineChartView.leftAxis.axisMinimum = 1
        timelineChartView.leftAxis.drawGridLinesEnabled = false
        timelineChartView.xAxis.drawGridLinesEnabled = false
        timelineChartView.xAxis.labelPosition = .bottom
        timelineChartView.rightAxis.drawGridLinesEnabled = false
        timelineChartView.rightAxis.drawLabelsEnabled = false
        timelineChartView.data = lineChartData
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
        months = []
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
}
