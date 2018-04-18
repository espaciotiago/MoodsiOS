//
//  TeamDayViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import Charts
import CoreData
import Alamofire

class TeamDayViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    @IBOutlet weak var dayPieCharView: PieChartView!
    @IBOutlet weak var latePieCharView: PieChartView!
    @IBOutlet weak var dayAverageText: UILabel!
    @IBOutlet weak var dayAverageImage: UIImageView!
    @IBOutlet weak var dayTotalAnsewrsText: UILabel!
    @IBOutlet weak var lateAverageText: UILabel!
    @IBOutlet weak var lateAverageImage: UIImageView!
    @IBOutlet weak var lateTotalAnswersText: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var textViewSelectTeam: UITextField!
    @IBOutlet weak var dropdownListTeams: UIPickerView!
    
    var months: [String]!
    var moodsInfo:[Double]!
    var moodsInfoTarde:[Double]!
    var currentDate:Date = Date()
    var controller:NSFetchedResultsController<UsserSession>!
    var controllerTeams:NSFetchedResultsController<Team>!
    var errorMessage = ""
    var userId = ""
    var teamId = ""
    var teamsIds = [String]()
    var teamsNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attemptFetch()
        attemptFetchTeams()
        //let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd"
        //currentDate = formatter.date(from: "2017/12/31")!
        
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
        
        labelDate.text = Constants().formatDate(date: currentDate)
        
        //Prepare the team selector options
        textViewSelectTeam.inputView = UIView(); // Hide keyboard, but show blinking cursor
        createListOfTeams()
        dropdownListTeams.isHidden = true
        //textViewSelectTeam.isEnabled = false
        textViewSelectTeam.addTarget(self, action:  #selector(myTargetFunction), for: .touchDown)
        dropdownListTeams.reloadAllComponents()
        
        months = ["Muy bien","Bien","Indiferente","Mal","Muy mal"]
        moodsInfo = []
        moodsInfoTarde = []
        loadCharts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     Prepare the segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? TeamWeekViewController {
            viewControllerB.currentDate = self.currentDate
        }else if let viewControllerB = segue.destination as? TeamMonthViewController {
            viewControllerB.currentDate = self.currentDate
        }else if let viewControllerB = segue.destination as? BarsEventsViewController {
            viewControllerB.teamId = self.teamId
            viewControllerB.userId = self.userId
            viewControllerB.currentDate = self.currentDate
        }
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
     Click on bar report statsToEvents
     */
    @IBAction func onBarsClick(_ sender: Any) {
        performSegue(withIdentifier: "statsToEvents", sender: self)
    }
    
    /*
     Get the info from DB
     */
    func loadCharts(){
        //Create the JSON to send
        let parameters: Parameters = [
            "idusuario": userId,
            "idequipo": teamId,
            "fecha": Constants().formatDate(date: currentDate),
            "indicador": "D",
        ]
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
                                    //Get the day chart data
                                    if(body != nil){
                                        let jornada_dia = body?.object(forKey: "jornada_dia") as? NSDictionary
                                        let moodDia = jornada_dia?.object(forKey: "moods") as? NSArray
                                        let promedioDia = jornada_dia?.object(forKey: "promedio") as? String
                                        let respuestas_esperadasDia = jornada_dia?.object(forKey: "respuestas_esperadas") as? String
                                        let total_respuestas_enviadasDia = jornada_dia?.object(forKey: "total_respuestas_enviadas") as? String
                                        let jornada_tarde = body?.object(forKey: "jornada_tarde") as? NSDictionary
                                        let moodTarde = jornada_tarde?.object(forKey: "moods") as? NSArray
                                        let promedioTarde = jornada_tarde?.object(forKey: "promedio") as? String
                                        let respuestas_esperadasTarde = jornada_tarde?.object(forKey: "respuestas_esperadas") as? String
                                        let total_respuestas_enviadasTarde = jornada_tarde?.object(forKey: "total_respuestas_enviadas") as? String
                                        var moodsDayValues = [Double]()
                                        var moodsDayValuesQ = 0.0
                                        var moodsLateValues = [Double]()
                                        var moodsLateValuesQ = 0.0
                                        if(moodDia != nil){
                                            for i in 0..<moodDia!.count {
                                                let mood = moodDia![i] as? NSDictionary
                                                if(mood != nil){
                                                    let cantidad = mood?.object(forKey: "cantidad") as? String
                                                    let value = mood?.object(forKey: "valor") as? String
                                                    if(cantidad != nil && value != nil){
                                                        let q = Double(cantidad!)
                                                        self.moodsInfo.append(q!)
                                                        let v = Double(value!)
                                                        moodsDayValuesQ = moodsDayValuesQ + q!
                                                        moodsDayValues.append(v!*q!)
                                                    }
                                                }
                                            }
                                        }
                                        if(moodTarde != nil){
                                            for i in 0..<moodTarde!.count {
                                                let mood = moodTarde![i] as? NSDictionary
                                                if(mood != nil){
                                                    let cantidad = mood?.object(forKey: "cantidad") as? String
                                                    let value = mood?.object(forKey: "valor") as? String
                                                    if(cantidad != nil && value != nil){
                                                        let q = Double(cantidad!)
                                                        self.moodsInfoTarde.append(q!)
                                                        let v = Double(value!)
                                                        moodsLateValuesQ = moodsLateValuesQ + q!
                                                        moodsLateValues.append(v!*q!)
                                                    }
                                                }
                                            }
                                        }
                                        self.setChartDataDay(dataPoints: self.months, values: self.moodsInfo)
                                        self.setChartDataLate(dataPoints: self.months, values: self.moodsInfoTarde)
                                        self.dayAverageText.text = "\(Constants().calculateAverage(numbers: moodsDayValues, total: moodsDayValuesQ))"
                                        self.lateAverageText.text = "\(Constants().calculateAverage(numbers: moodsLateValues, total: moodsLateValuesQ))"
                                        self.dayTotalAnsewrsText.text = total_respuestas_enviadasDia
                                        self.lateTotalAnswersText.text = total_respuestas_enviadasTarde
                                        self.dayAverageImage.image = Constants().getImageOfProm(average: Constants().calculateAverage(numbers: moodsDayValues, total: moodsDayValuesQ))
                                        self.lateAverageImage.image = Constants().getImageOfProm(average: Constants().calculateAverage(numbers: moodsLateValues, total: moodsLateValuesQ))
                                    }
                                }else{ //Go to Error screen
                                    self.performSegue(withIdentifier: "ToErrorSegue", sender: self)
                                }
                            }else{ //Go to Error screen
                                //Algun error extraño - Conexión probablemente
                                self.errorMessage = "No se ha podido acceder al servidor, compruebe su conexión y vuelva a intentar"
                                self.performSegue(withIdentifier: "ToErrorSegue", sender: self)
                            }
        }
    }
    
    /**
     Sets the data in the cart view
     **/
    func setChartDataDay(dataPoints: [String], values: [Double]){
        //General Configurations of the linechart
        dayPieCharView.noDataText = "No hay datos disponibles para la fecha"
        let description = Description()
        description.text = ""
        dayPieCharView.chartDescription = description
        dayPieCharView.holeColor = NSUIColor(red:0.93, green:0.99, blue:1.00, alpha:1.0)
        //Set the charts
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Moods")
        let pieChartData = PieChartData()
        pieChartData.addDataSet(pieChartDataSet)
        //Set colors
        let colorGreen = UIColor(red:0.31, green:0.85, blue:0.53, alpha:1.0)
        let colorViolet = UIColor(red:0.72, green:0.30, blue:0.99, alpha:1.0)
        let colorYellow = UIColor(red:0.99, green:0.86, blue:0.29, alpha:1.0)
        let colorBlue = UIColor(red:0.44, green:0.74, blue:0.96, alpha:1.0)
        let colorRed = UIColor(red:0.96, green:0.21, blue:0.28, alpha:1.0)
        let colors: [UIColor] = [colorGreen,colorYellow,colorBlue,colorRed,colorViolet]
        pieChartDataSet.colors = colors
        dayPieCharView.data = pieChartData
    }
    
    /**
     Sets the data in the cart view
     **/
    func setChartDataLate(dataPoints: [String], values: [Double]){
        //General Configurations of the linechart
        latePieCharView.noDataText = "No hay datos disponibles para la fecha"
        let description = Description()
        description.text = ""
        latePieCharView.chartDescription = description
        latePieCharView.holeColor = NSUIColor(red:0.57, green:0.67, blue:0.76, alpha:1.0)
        //Set the charts
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Moods")
        let pieChartData = PieChartData()
        pieChartData.addDataSet(pieChartDataSet)
        //Set colors
        let colorGreen = UIColor(red:0.31, green:0.85, blue:0.53, alpha:1.0)
        let colorYellow = UIColor(red:0.99, green:0.86, blue:0.29, alpha:1.0)
        let colorViolet = UIColor(red:0.72, green:0.30, blue:0.99, alpha:1.0)
        let colorBlue = UIColor(red:0.44, green:0.74, blue:0.96, alpha:1.0)
        let colorRed = UIColor(red:0.96, green:0.21, blue:0.28, alpha:1.0)
        let colors: [UIColor] = [colorGreen,colorYellow,colorBlue,colorRed,colorViolet]
        pieChartDataSet.colors = colors
        latePieCharView.data = pieChartData
    }
    /* ----------------------------------------------------------------------------- */
    /* Actions */
    /* ----------------------------------------------------------------------------- */
    @IBAction func onClickWeek(_ sender: Any) {
        performSegue(withIdentifier: "toWeekSegue", sender: self)
    }
    @IBAction func onClickMonth(_ sender: Any) {
        performSegue(withIdentifier: "toMonthSegue", sender: self)
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
        months = ["Muy bien","Bien","Indiferente","Mal","Muy mal"]
        moodsInfo = []
        moodsInfoTarde = []
        loadCharts()
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
