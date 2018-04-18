//
//  LoadingViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 3/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class LoadingViewController: UIViewController, NSFetchedResultsControllerDelegate {

    
    @IBOutlet weak var imgMood1: UIImageView!
    @IBOutlet weak var imgMood2: UIImageView!
    @IBOutlet weak var imgMood3: UIImageView!
    @IBOutlet weak var imgMood4: UIImageView!
    var index=0
    var countdownTimer: Timer!
    var isUserLoged = false
    var isLeader = false
    var userId = ""
    var errorMessage:String = ""
    var controller:NSFetchedResultsController<UsserSession>!
    var paramsController:NSFetchedResultsController<Params>!
    var teamsController:NSFetchedResultsController<Team>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgMood1.isHidden = true
        imgMood2.isHidden = true
        imgMood3.isHidden = true
        imgMood4.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Verify if there is a user logged in BD - TODO
        attemptFetch()
        var howManyUsers = 0
        if let sections = controller.sections {
            print("Fetching sections...")
            print("\(sections)")
            let sectionInfo = sections[0]
            print("\(sectionInfo)")
            howManyUsers = sectionInfo.numberOfObjects
            if(howManyUsers > 0){
                isUserLoged = true
                let userLoged = sectionInfo.objects![0] as! UsserSession
                self.userId = userLoged.id_server!
            }
        }
        
        if(isUserLoged){
            self.countdownTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            //Get the Params of the user
            //Create the JSON to send
            let parameters: Parameters = [
                "idusuario": userId,
                "jornada": ""
            ]
            //Send info to the server and verify
            Alamofire.request(Constants.GET_PARAMS_URL,
                              method: .post,
                              parameters:parameters,
                              encoding: JSONEncoding.default).responseJSON { response in
                                
                                //Json response parse
                                if let json:NSDictionary = response.result.value as? NSDictionary {
                                    //Get values from response
                                    let ans:Int = json.object(forKey: "ans") as! Int
                                    let body:NSDictionary = (json.object(forKey: "body") as? NSDictionary)!
                                    self.errorMessage = json.object(forKey: "error") as! String
                                    
                                    if(ans == 1){
                                        //TODO Save the info in DB
                                        let envioMoodJornada = body.object(forKey: "envio_mood_jornada") as? Int
                                        let parametros_compania = body.object(forKey: "parametros_compania") as? NSDictionary
                                        var hora_fin = parametros_compania?.object(forKey: "hora_fin") as? String
                                        if(hora_fin != nil){
                                            hora_fin = hora_fin! + ":00"
                                        }
                                        var hora_inicio = parametros_compania?.object(forKey: "hora_inicio") as? String
                                        if(hora_inicio != nil){
                                            hora_inicio = hora_inicio! + ":00"
                                        }
                                        var semana_laboral = parametros_compania?.object(forKey: "semana_laboral") as? String
                                        let umbral = parametros_compania?.object(forKey: "umbral") as? String
                                        var umbralDouble = 0.0
                                        if(umbral != nil){
                                            umbralDouble = Double(umbral!)!
                                        }
                                        let equipos = body.object(forKey: "equipos") as? NSArray
                                        let equipos_lider = body.object(forKey: "equipos_lider") as? NSArray
                                        //Update stuff in database
                                        self.attemptFetchParams()
                                        self.attemptFetchTeams()
                                        //Save teams info in db and update the params with the teams info params
                                        if(equipos != nil){
                                            for i in 0..<equipos!.count{
                                                let equipo = equipos![i] as? NSDictionary
                                                if(equipo != nil){
                                                    let equipo_hora_inicio = equipo?.object(forKey: "hora_inicio") as? String
                                                    let equipo_hora_fin = equipo?.object(forKey: "hora_fin") as? String
                                                    let idequipo = equipo?.object(forKey: "idequipo") as? String
                                                    let nombre = equipo?.object(forKey: "nombre") as? String
                                                    let equipo_semana_laboral = equipo?.object(forKey: "semana_laboral") as? String
                                                    
                                                    if(equipo_hora_inicio != nil && !(equipo_hora_inicio?.isEmpty)!){
                                                        hora_inicio = equipo_hora_inicio! + ":00"
                                                    }
                                                    if(equipo_hora_fin != nil && !(equipo_hora_fin?.isEmpty)!){
                                                        hora_fin = equipo_hora_fin! + ":00"
                                                    }
                                                    if(idequipo != nil && !(idequipo?.isEmpty)!){
                                                        
                                                    }
                                                    if(nombre != nil && !(nombre?.isEmpty)!){
                                                        
                                                    }
                                                    if(equipo_semana_laboral != nil && !(equipo_semana_laboral?.isEmpty)!){
                                                        semana_laboral = equipo_semana_laboral
                                                    }
                                                    //TODO Save the team
                                                    if let sections = self.teamsController.sections {
                                                        let sectionInfo = sections[0]
                                                        let howManyTeams = sectionInfo.numberOfObjects
                                                        if(howManyTeams > 0){
                                                            //Verify if the team alreadi exist
                                                            var exists = false
                                                            var index = 0
                                                            for i in 0..<howManyTeams{
                                                                let teamInDb = sectionInfo.objects![i] as! Team
                                                                if(teamInDb.team_id == idequipo){
                                                                    exists = true
                                                                    index = i
                                                                    break
                                                                }
                                                            }
                                                            if(exists){
                                                                //Update the team
                                                                let team = sectionInfo.objects![index] as! Team
                                                                team.team_id = idequipo
                                                                team.name = nombre
                                                            }else{
                                                                //Create the team
                                                                let team = Team(context:context)
                                                                team.name = nombre
                                                                team.team_id = idequipo
                                                            }
                                                        }else{
                                                            //Create the team
                                                            let team = Team(context:context)
                                                            team.name = nombre
                                                            team.team_id = idequipo
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        //Save teams leader info in db and update the params with the teams info params
                                        if(equipos_lider != nil){
                                            // Save the team
                                            for i in 0..<equipos_lider!.count{
                                                let equipo = equipos_lider![i] as? NSDictionary
                                                if(equipo != nil){
                                                    let equipo_hora_inicio = equipo?.object(forKey: "hora_inicio") as? String
                                                    let equipo_hora_fin = equipo?.object(forKey: "hora_fin") as? String
                                                    let idequipo = equipo?.object(forKey: "idequipo") as? String
                                                    let nombre = equipo?.object(forKey: "nombre") as? String
                                                    let equipo_semana_laboral = equipo?.object(forKey: "semana_laboral") as? String
                                                    // Save the team
                                                    if let sections = self.teamsController.sections {
                                                        let sectionInfo = sections[0]
                                                        let howManyTeams = sectionInfo.numberOfObjects
                                                        if(howManyTeams > 0){
                                                            //Verify if the team alreadi exist
                                                            var exists = false
                                                            var index = 0
                                                            for i in 0..<howManyTeams{
                                                                let teamInDb = sectionInfo.objects![i] as! Team
                                                                if(teamInDb.team_id == idequipo){
                                                                    exists = true
                                                                    index = i
                                                                    break
                                                                }
                                                            }
                                                            if(exists){
                                                                //Update the team
                                                                let team = sectionInfo.objects![index] as! Team
                                                                team.team_id = idequipo
                                                                team.name = nombre
                                                            }else{
                                                                //Create the team
                                                                let team = Team(context:context)
                                                                team.name = nombre
                                                                team.team_id = idequipo
                                                            }
                                                        }else{
                                                            //Create the team
                                                            let team = Team(context:context)
                                                            team.name = nombre
                                                            team.team_id = idequipo
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Save the info in params table
                                        if let sections = self.paramsController.sections {
                                            let sectionInfo = sections[0]
                                            let howManyParams = sectionInfo.numberOfObjects
                                            if(howManyParams > 0){
                                                //There are params already - update
                                                let params = sectionInfo.objects![0] as! Params
                                                params.end_hour = hora_fin
                                                params.start_hour = hora_inicio
                                                params.laboral_days = semana_laboral
                                                params.threshold = umbralDouble
                                            }else{
                                                //There are not params - Create
                                                let params = Params(context:context)
                                                params.end_hour = hora_fin
                                                params.start_hour = hora_inicio
                                                params.laboral_days = semana_laboral
                                                params.threshold = umbralDouble
                                            }
                                        }
                                        ad.saveContext()
                                        //Finish loading and go to the main screen
                                        self.endTimer()
                                        self.performSegue(withIdentifier: "LoadingToMainSegue", sender: self)
                                    }else{ //Go to Error screen
                                        self.performSegue(withIdentifier: "ToErrorSegue", sender: self)
                                    }
                                }else{ //Go to Error screen
                                    //Algun error extraño - Conexión probablemente
                                    self.errorMessage = "No se ha podido acceder al servidor, compruebe su conexión y vuelv aa intentar"
                                    self.performSegue(withIdentifier: "ToErrorSegue", sender: self)
                                }
            }
        }else{
            //Go back to login
            print("GO TO LOGIN")
            //Finish loading and go to the next screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(controller, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateTime() {
        creeateLoaderFaces()
    }
    
    func endTimer() {
        self.countdownTimer.invalidate()
    }
    
    func creeateLoaderFaces() {
        self.index = self.index+1
        if(self.index==1){
            self.imgMood1.isHidden = false
        }else if(self.index==2){
            self.imgMood2.isHidden = false
        }else if(self.index==3){
            self.imgMood3.isHidden = false
        }else if(self.index==4){
            self.imgMood4.isHidden = false
        }else if(self.index==5){
            self.index = 0
            self.imgMood1.isHidden = true
            self.imgMood2.isHidden = true
            self.imgMood3.isHidden = true
            self.imgMood4.isHidden = true
        }
    }
    
    /*
     Prepare the segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? MainViewController {
            viewControllerB.isLeader = self.isLeader
        }
        else if let viewControllerB = segue.destination as? ErrorViewController {
            viewControllerB.errorStr = self.errorMessage
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
    func attemptFetchParams(){
        let fetchRequest:NSFetchRequest<Params> = Params.fetchRequest()
        let defaultSort = NSSortDescriptor(key: "start_hour", ascending: false)
        fetchRequest.sortDescriptors = [defaultSort]
        
        paramsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do{
            try paramsController.performFetch()
        }catch{
            let error = error as NSError
            print("Error fetching: \(error)")
        }
    }
    func attemptFetchTeams(){
        let fetchRequest:NSFetchRequest<Team> = Team.fetchRequest()
        let defaultSort = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [defaultSort]
        
        teamsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do{
            try teamsController.performFetch()
        }catch{
            let error = error as NSError
            print("Error fetching: \(error)")
        }
    }
}
