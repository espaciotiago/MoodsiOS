//
//  EventViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class EventViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var textOther: UITextField!
    @IBOutlet weak var imgMoodSelected: UIImageView!
    @IBOutlet weak var eventTableView: UITableView!
    
    var mood:String = ""
    var moodId:String = ""
    var moodValue = 0
    var events = [Event]()
    var selectedEvent:Event = Event(idInServer: "", label: "", extraText: "", checked: false)
    var errorMessage = ""
    var userId = ""
    var teamId = ""
    var jornada = 1
    
    var controller:NSFetchedResultsController<UsserSession>!
    var controllerTeams:NSFetchedResultsController<Team>!
    var controllerParams:NSFetchedResultsController<Params>!

    override func viewDidLoad() {
        super.viewDidLoad()
        textOther.isHidden = true
        setTheImageOfSelectedMood()
        eventTableView.separatorStyle = .none
        //Get the id of the loged user
        attemptFetch()
        attemptFetchTeams()
        attemptFetchParams()
        //Get the user legged
        var howManyUsers = 0
        if let sections = controller.sections {
            let sectionInfo = sections[0]
            howManyUsers = sectionInfo.numberOfObjects
            if(howManyUsers > 0){
                let userLoged = sectionInfo.objects![0] as! UsserSession
                self.userId = userLoged.id_server!
            }
        }
        print("User: \(userId)")
        //Get the default (first) team saved
        var howManyTeams = 0
        if let sections = controllerTeams.sections {
            let sectionInfo = sections[0]
            howManyTeams = sectionInfo.numberOfObjects
            if(howManyTeams > 0){
                let team = sectionInfo.objects![0] as! Team
                self.teamId = team.team_id!
            }
        }
        //Get the params and the jornada
        var howManyParams = 0
        if let sections = controllerParams.sections {
            let sectionInfo = sections[0]
            howManyParams = sectionInfo.numberOfObjects
            if(howManyParams > 0){
                let params = sectionInfo.objects![0] as! Params
                let startHour = params.start_hour!
                let endHour = params.end_hour!
                print("ST: \(startHour) EH: \(endHour)")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss" //Your date format
                let dateSH = dateFormatter.date(from: startHour)
                let dateEH = dateFormatter.date(from: endHour)
                let dateNowFull = Date()
                let dateNowStr = dateFormatter.string(from: dateNowFull)
                let dateNowHour = dateFormatter.date(from: dateNowStr)
                //get the jornada
                // Compare now wih start
                if dateNowHour?.compare(dateSH!) == .orderedDescending && dateNowHour?.compare(dateEH!) == .orderedAscending{
                    jornada = 1
                }else if dateNowHour?.compare(dateEH!) == .orderedDescending{
                    jornada = 2
                }else if dateNowHour?.compare(dateSH!) == .orderedAscending{
                    jornada = 2
                }
            }
        }
        print("Jornada: \(jornada)")
        //Load the events
        loadEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Set the image of a selected mood
     **/
    func setTheImageOfSelectedMood(){
        if(moodId == "mood_1"){
            imgMoodSelected.image = #imageLiteral(resourceName: "mood_happy")
        }else if(moodId == "mood_2"){
            imgMoodSelected.image = #imageLiteral(resourceName: "mood_normal")
        }else if(moodId == "mood_3"){
            imgMoodSelected.image = #imageLiteral(resourceName: "mood_sad")
        }else if(moodId == "mood_4"){
            imgMoodSelected.image = #imageLiteral(resourceName: "mood_angry")
        }else if(moodId == "mood_5"){
            imgMoodSelected.image = #imageLiteral(resourceName: "mood_5")
        }
    }
    
    /*
     Action: Clck on Send -> Do verufy info and send the mood
     */
    @IBAction func onClickSend(_ sender: Any) {
        if(!selectedEvent.idInServer.isEmpty){
            let txtOther = textOther.text
            if(selectedEvent.idInServer=="evento_4"){
                if(txtOther?.isEmpty)!{
                    //Is needed, show warning
                    showAlert(title: "Warning", message: "¿Cúal? Es un campo obligatorio")
                }else{
                    selectedEvent.extraText = txtOther!
                }
            }
            let moodToSend = Mood(idInServer: moodId, mood: mood, value: moodValue)
            let workDay = jornada //TODO Calculate
            var currentDate = "" //TODO Calculate
            let responseMood = ResponseMood(mood: moodToSend, event: selectedEvent, workday: workDay, currentDate: currentDate, eventText: selectedEvent.extraText)
            
            //Sent the mood -------> Do in background
            let error = false
            if(error){
                errorMessage = "No se ha podido acceder al servidor ¿? :$"
                performSegue(withIdentifier: "sendMoodErrorSegue", sender: self)
            }else{
                sendMood(mood: responseMood)
            }
        }else{
            showAlert(title: "Warning", message: "Un evento debe ser seleccionado")
        }
    }
    
    /*
     Send the info of the mood to the server
     */
    func sendMood(mood:ResponseMood){
        //Create the JSON to send
        let parameters: Parameters = [
            "idusuario": userId,
            "idequipo": teamId,
            "jornada": mood.workday,
            "valor": mood.mood.value,
            "texto_evento": mood.eventText,
            "idevento": mood.event.idInServer,
            "idmood": mood.mood.idInServer
            ]
        //Send info to the server and verify
        Alamofire.request(Constants.SEND_MOOD_URL,
                          method: .post,
                          parameters:parameters,
                          encoding: JSONEncoding.default).responseJSON { response in
                            
                            //Json response parse
                            if let json:NSDictionary = response.result.value as? NSDictionary {
                                //Get values from response
                                let ans:Int = json.object(forKey: "ans") as! Int
                                let body = json.object(forKey: "body") as? NSArray
                                self.errorMessage = json.object(forKey: "error") as! String
                                
                                if(ans == 1){
                                    self.performSegue(withIdentifier: "sendMoodSuccessSegue", sender: self)
                                }else{ //Go to Error screen
                                    self.performSegue(withIdentifier: "sendMoodErrorSegue", sender: self)
                                }
                            }else{ //Go to Error screen
                                //Algun error extraño - Conexión probablemente
                                self.errorMessage = "No se ha podido acceder al servidor, compruebe su conexión y vuelv aa intentar"
                                self.performSegue(withIdentifier: "sendMoodErrorSegue", sender: self)
                            }
        }
    }
    
    
    /*
     Load the events from the server
     */
    private func loadEvents(){
        //Create the JSON to send
        let parameters: Parameters = [
            "idusuario": userId,
            ]
        //Send info to the server and verify
        Alamofire.request(Constants.GET_EVENTS_URL,
                          method: .post,
                          parameters:parameters,
                          encoding: JSONEncoding.default).responseJSON { response in
                            
                            //Json response parse
                            if let json:NSDictionary = response.result.value as? NSDictionary {
                                //Get values from response
                                let ans:Int = json.object(forKey: "ans") as! Int
                                let body = json.object(forKey: "body") as? NSArray
                                self.errorMessage = json.object(forKey: "error") as! String
                                
                                if(ans == 1){
                                    //Get the Events
                                    if(body != nil){
                                        for i in 0..<body!.count{
                                            let event = body![i] as? NSDictionary
                                            if(event != nil){
                                                let idInServer = event?.object(forKey: "idevento") as? String
                                                let label = event?.object(forKey: "nombre") as? String
                                                let eventToCreate = Event(idInServer: idInServer!, label: label!, extraText: "", checked: false)
                                                self.events.append(eventToCreate)
                                            }
                                        }
                                        self.eventTableView.reloadData()
                                    }
                                }else{ //Go to Error screen
                                    self.performSegue(withIdentifier: "sendMoodErrorSegue", sender: self)
                                }
                            }else{ //Go to Error screen
                                //Algun error extraño - Conexión probablemente
                                self.errorMessage = "No se ha podido acceder al servidor, compruebe su conexión y vuelv aa intentar"
                                self.performSegue(withIdentifier: "sendMoodErrorSegue", sender: self)
                            }
        }
    }
    
    /**
     Show an alert
     **/
    func showAlert(title:String,message:String){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
     Prepare the info to send in the segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? ErrorViewController {
            viewControllerB.errorStr = errorMessage
        }
    }
    
    /*------------------------------------------------------------------------------------------------------------
     Table view stuff
     ------------------------------------------------------------------------------------------------------------*/
    /*
     Total of cells
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    /*
     Initialises the cells
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell
        let event = events[indexPath.row]
        //Set the info of the cell
        cell.labelEvent.text = event.label
        //If is other - Show the txtOther
        if(event.idInServer=="evento_4" && event.checked){
            textOther.isHidden = false
        }else{
            textOther.isHidden = true
        }
        //Verify if is checked
        if(event.checked){
            cell.labelEvent.textColor = UIColor(red:0.44, green:0.74, blue:0.96, alpha:1.0)
        }else{
            cell.labelEvent.textColor = UIColor(red:0.82, green:0.83, blue:0.84, alpha:1.0)
        }
        return cell
    }
    /*
     When click on a cell
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:EventTableViewCell = tableView.cellForRow(at: indexPath)! as! EventTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
        cell.selectedBackgroundView = backgroundView
        
        removeAllSelected()
        events[indexPath.row].checked = !events[indexPath.row].checked
        selectedEvent = events[indexPath.row]
        if(events[indexPath.row].idInServer=="evento_4" && events[indexPath.row].checked){
            textOther.isHidden = false
        }
        //Verify if is checked, not sure what for
        if(events[indexPath.row].checked){
            cell.labelEvent.textColor = UIColor(red:0.44, green:0.74, blue:0.96, alpha:1.0)
        }else{
            cell.labelEvent.textColor = UIColor(red:0.82, green:0.83, blue:0.84, alpha:1.0)
        }
        tableView.reloadData()
    }
    
    /* Remove the selected items before */
    func removeAllSelected(){
        for i in 0..<events.count{
            events[i].checked = false
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
