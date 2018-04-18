//
//  MainViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 3/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class MainViewController: UIViewController {
    
    @IBOutlet weak var timelineView: UIStackView!
    @IBOutlet weak var moodsView: UIStackView!
    @IBOutlet weak var formsView: UIStackView!
    @IBOutlet weak var campaignView: UIStackView!
    @IBOutlet weak var imgMoodsOption: UIImageView!
    @IBOutlet weak var labelMoodsOption: UILabel!
    @IBOutlet weak var labelInit: UILabel!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var btnCloseSesion: UIButton!
    
    
    var isLeader = false
    var jornada = 0
    var controller:NSFetchedResultsController<UsserSession>!
    var controllerParams:NSFetchedResultsController<Params>!

    override func viewDidLoad() {
        super.viewDidLoad()
        labelInit.text = Constants().getRandomPhrase()
        attemptFetch()
        attemptFetchParams()
        //Verify rol of loged user
        var howManyUsers = 0
        if let sections = controller.sections {
            let sectionInfo = sections[0]
            howManyUsers = sectionInfo.numberOfObjects
            if(howManyUsers > 0){
                let userLoged = sectionInfo.objects![0] as! UsserSession
                let rol = userLoged.rol_id!
                if(rol=="rol_1"){
                    isLeader = false
                }else{
                    isLeader = true
                }
            }
        }
        
        //TODO
        print("HORA TO SET: \("hora_fin")")
        setAlarm(hour: 14, minute: 00,id: "pizza.reminder",cat: "pizza.reminder.day")
        setAlarm(hour: 14, minute: 42, id: "p.reminder",cat: "pizza.reminder.late")
        
        //Verify start hour and end hour of params
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
                // Compare now wih start
                if dateNowHour?.compare(dateSH!) == .orderedDescending && dateNowHour?.compare(dateEH!) == .orderedAscending{
                    print("\(dateFormatter.string(from: dateNowHour!)) es Despues que \(dateFormatter.string(from: dateSH!)) y Antes de \(dateFormatter.string(from: dateEH!))")
                    jornada = 0
                }else if dateNowHour?.compare(dateEH!) == .orderedDescending{
                    print("\(dateFormatter.string(from: dateNowHour!)) es Despues que \(dateFormatter.string(from: dateEH!))")
                    jornada = 1
                }else if dateNowHour?.compare(dateSH!) == .orderedAscending{
                    print("\(dateFormatter.string(from: dateNowHour!)) es Antes que \(dateFormatter.string(from: dateSH!))")
                    jornada = 1
                }
                
                if(jornada == 0){
                    let color = UIColor(red:0.93, green:0.99, blue:1.00, alpha:1.0)
                    mainView.backgroundColor = color
                }else{
                    let color = UIColor(red:0.57, green:0.67, blue:0.76, alpha:1.0)
                    let colorWhite = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
                    mainView.backgroundColor = color
                    btnCloseSesion.tintColor = colorWhite
                    labelInit.textColor = colorWhite
                }
            }
        }
        //Set the scree for lider or colaborador
        if(isLeader){
            //All the options for the Lider rol
            //Hide the timelineview
            self.timelineView.isHidden = false
            //Set the incon and text of the moodview -> teamview
            self.imgMoodsOption.image = #imageLiteral(resourceName: "teams_icon")
            self.labelMoodsOption.text = "Mi equipo"
            //Actions in bottom menu
            //Teams
            let gestureTeams = UITapGestureRecognizer(target: self, action:  #selector (self.onClickTeams(sender:)))
            self.moodsView.addGestureRecognizer(gestureTeams)
        }else{
            //All the options for the colaborador rol
            self.timelineView.isHidden = true
            //Actions in bottom menu
            //Moods
            let gestureMoods = UITapGestureRecognizer(target: self, action:  #selector (self.onClickMoods(sender:)))
            self.moodsView.addGestureRecognizer(gestureMoods)
        }
        //Actions in bottom menu
        //Timeline
        let gestureTimeline = UITapGestureRecognizer(target: self, action:  #selector (self.onClickTimeline(sender:)))
        self.timelineView.addGestureRecognizer(gestureTimeline)
        //Forms
        let gestureForms = UITapGestureRecognizer(target: self, action:  #selector (self.onClickForms(sender:)))
        self.formsView.addGestureRecognizer(gestureForms)
        //Campaign
        let gestureCampaign = UITapGestureRecognizer(target: self, action:  #selector (self.onClickCampaign(sender:)))
        self.campaignView.addGestureRecognizer(gestureCampaign)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Actions in the menu
     **/
    @objc func onClickMoods(sender : UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MoodsViewController")
        self.present(controller, animated: true, completion: nil)
    }
    @objc func onClickTeams(sender : UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TeamDayViewController")
        self.present(controller, animated: true, completion: nil)
    }
    @objc func onClickTimeline(sender : UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TimelineViewController")
        self.present(controller, animated: true, completion: nil)
    }
    @objc func onClickForms(sender : UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FormsViewController")
        self.present(controller, animated: true, completion: nil)
    }
    @objc func onClickCampaign(sender : UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CampaignViewController")
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func onClickClose(_ sender: Any) {
        //Close session
        //Delete user session in database
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "UsserSession")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        //Delete Params in database
        let deleteFetchParams = NSFetchRequest<NSFetchRequestResult>(entityName: "Params")
        let deleteRequestParams = NSBatchDeleteRequest(fetchRequest: deleteFetchParams)
        //Delete Teams in database
        let deleteFetchTemas = NSFetchRequest<NSFetchRequestResult>(entityName: "Team")
        let deleteRequestTemas = NSBatchDeleteRequest(fetchRequest: deleteFetchTemas)
        
        do {
            //Execute the delete
            try context.execute(deleteRequest)
            try context.execute(deleteRequestParams)
            try context.execute(deleteRequestTemas)
            try context.save()
        } catch {
            print ("There was an error")
        }
        //Close
        exit(0)
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
    
    /**
     *
     */
    func setAlarm(hour:Int,minute:Int,id:String,cat:String){
        //Try the notification
        let content = UNMutableNotificationContent()
        content.subtitle = "¿Cómo te sinetes hoy?"
        content.title = "Moods"
        content.badge = 1
        content.categoryIdentifier = cat
        
        var dateComponents = DateComponents()
        // a more realistic example for Gregorian calendar. Every Monday at 11:30AM
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("error in pizza reminder: \(error.localizedDescription)")
            }
        }
        print("added notification:\(request.identifier)")
        print("att:\(dateComponents)")
    }

}
