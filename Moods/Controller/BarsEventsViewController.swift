//
//  BarsEventsViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 5/02/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import Charts
import Alamofire

class BarsEventsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    static let MOOD_PREFIX:String = "mood_";
    static let NUMBER_OF_MOODS:Int = 5;
    
    @IBOutlet weak var tableviewBars: UITableView!
    
    var eventsContainers = [MoodEventContainer]()
    var teamId:String?
    var userId:String?
    var currentDate:Date?
    var errorMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     Load the week data from the server
     */
    func loadData(){
        
        //Create the JSON to send
        let parameters: Parameters = [
            "idusuario": userId,
            "idequipo": teamId,
            "fecha": Constants().formatDate(date: currentDate!)
        ]
        //Send info to the server and verify
        Alamofire.request(Constants.GET_BARS_URL,
                          method: .post,
                          parameters:parameters,
                          encoding: JSONEncoding.default).responseJSON { response in
                            
                            //Json response parse
                            if let json:NSDictionary = response.result.value as? NSDictionary {
                                //Get values from response
                                
                                for i in 0..<5 {
                                    let val = i+1
                                    let idmood = "mood_\(val)"
                                    let moodArray = json.object(forKey: idmood) as? NSArray
                                    var arrayEvents = [MoodEventResponse]()
                                    if((moodArray) != nil){
                                        for j in 0..<moodArray!.count{
                                            let merJson = moodArray![j] as! NSDictionary
                                            var nombre = merJson.object(forKey: "nombre") as? String
                                            let idevento = merJson.object(forKey: "idevento") as? String
                                            var cantidad = merJson.object(forKey: "cantidad") as? String
                                            var cantNum = 0;
                                            if(cantidad != nil && !(cantidad?.isEmpty)!){
                                                cantNum = Int(cantidad!)!
                                            }
                                            if(nombre == nil){
                                                nombre = ""
                                            }
                                            let mer = MoodEventResponse(idInServer: idevento!, label: nombre!, quantity: cantNum)
                                            arrayEvents.append(mer)
                                        }
                                    }
                                    var m = MoodEventContainer()
                                    
                                    switch (idmood){
                                    case "mood_1":
                                        m = MoodEventContainer(moodsEventResponseList: arrayEvents,moodTitle: "Muy Bien",resource: 0);
                                        break
                                    case "mood_2":
                                        m = MoodEventContainer(moodsEventResponseList: arrayEvents,moodTitle: "Bien",resource: 1);
                                        break
                                    case "mood_3":
                                        m = MoodEventContainer(moodsEventResponseList: arrayEvents,moodTitle: "Mal",resource: 2);
                                        break
                                    case "mood_4":
                                        m = MoodEventContainer(moodsEventResponseList: arrayEvents,moodTitle: "Muy Mal",resource: 3);
                                        break
                                    case "mood_5":
                                        m = MoodEventContainer(moodsEventResponseList: arrayEvents,moodTitle: "Indiferente",resource: 4);
                                        break
                                    default:
                                        break
                                    }
                                    
                                    self.eventsContainers.append(m)
                                }
                                
                                self.tableviewBars.reloadData()
                                
                                /*if(ans == 1){
                                    }
                                }else{ //Go to Error screen
                                    self.performSegue(withIdentifier: "ToErrorSegue", sender: self)
                                }*/
                            }else{ //Go to Error screen
                                //Algun error extraño - Conexión probablemente
                                self.errorMessage = "No se ha podido acceder al servidor, compruebe su conexión y vuelv aa intentar"
                                self.performSegue(withIdentifier: "ToErrorSegue", sender: self)
                            }
        }
    }
    
    /*----------------------------------------------------------------------------------------------
     Table view stuff
     ----------------------------------------------------------------------------------------------*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsContainers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoodEventResponseTableViewCell", for: indexPath) as! MoodEventResponseTableViewCell
        
        let event = eventsContainers[indexPath.row]
        //Set the info of the cell
        if(event.resource==0){
            cell.imgMood.image = #imageLiteral(resourceName: "mood_happy")
        }else if(event.resource==1){
            cell.imgMood.image = #imageLiteral(resourceName: "mood_normal")
        }else if(event.resource==2){
            cell.imgMood.image = #imageLiteral(resourceName: "mood_sad")
        }else if(event.resource==3){
            cell.imgMood.image = #imageLiteral(resourceName: "mood_angry")
        }else if(event.resource==4){
            cell.imgMood.image = #imageLiteral(resourceName: "mood_5")
        }else{
            cell.imgMood.image = #imageLiteral(resourceName: "mood_icon")
        }
        cell.titleMood.text = event.moodTitle
        cell.selectedEvent.text = ""
        
        //General Configurations of the linechart
        cell.barChart.noDataText = "No hay datos disponibles para la fecha"
        //Set the charts
        var dataEntries: [BarChartDataEntry] = []
        var labels: [String] = []
        for i in 0..<event.moodsEventResponseList.count {
            let num:Int = event.moodsEventResponseList[i].quantity
            
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(num))
            labels.append(event.moodsEventResponseList[i].label)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Cantidad de selecciones")
        let chartData = BarChartData()
        chartData.addDataSet(chartDataSet)
        //Axex setup
        let formato:LineChartFormatter = LineChartFormatter()
        formato.months = labels
        cell.labels = labels
        let xaxis:XAxis = XAxis()
        for i in 0..<formato.months.count {
            formato.stringForValue(Double(i), axis: xaxis)
            xaxis.valueFormatter = formato
        }
        //cell.barChart.xAxis.valueFormatter = formato
        cell.barChart.leftAxis.drawGridLinesEnabled = false
        cell.barChart.leftAxis.drawGridLinesEnabled = false
        cell.barChart.xAxis.drawGridLinesEnabled = false
        cell.barChart.xAxis.labelPosition = .bottom
        cell.barChart.rightAxis.drawGridLinesEnabled = false
        cell.barChart.rightAxis.drawLabelsEnabled = false
        cell.barChart.descriptionText = ""
        cell.barChart.data = chartData
        
        return cell
    }
    
    /*
     When click on a cell
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:MoodEventResponseTableViewCell = tableView.cellForRow(at: indexPath)! as! MoodEventResponseTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
        cell.selectedBackgroundView = backgroundView
    }

}
