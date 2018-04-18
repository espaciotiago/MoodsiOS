//
//  FormsViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class FormsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var formsTableView: UITableView!
    
    var controller:NSFetchedResultsController<UsserSession>!
    var forms = [Form]()
    var selectedForm:Form!
    var errorMessage:String = ""
    var userId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        attemptFetch()
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
        //Load the forms
        loadForms()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     Prepare the info to send in the segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? QuestionsViewController {
            viewControllerB.form = selectedForm
            viewControllerB.userId = userId
        }
    }
    
    /*
     Load the forms from the server
     */
    func loadForms() {
        //Create the JSON to send
        let parameters: Parameters = [
            "idusuario": userId,
        ]
        //Send info to the server and verify
        Alamofire.request(Constants.GET_FORMS_URL,
                          method: .post,
                          parameters:parameters,
                          encoding: JSONEncoding.default).responseJSON { response in
                            
                            //Json response parse
                            if let json:NSDictionary = response.result.value as? NSDictionary {
                                print("JSON: \(json)")
                                //Get values from response
                                let ans:Int = json.object(forKey: "ans") as! Int
                                let body = json.object(forKey: "body") as? NSArray
                                self.errorMessage = json.object(forKey: "error") as! String
                                
                                if(ans == 1){
                                    //Get the forms
                                    if(body != nil){
                                       //Loop the forms
                                        for i in 0 ..< body!.count{
                                            //Get a form
                                            let form = body![i] as? NSDictionary
                                            //Get the info in the form
                                            let id = form?.object(forKey: "idencuesta") as? String
                                            let name = form?.object(forKey: "nombre") as? String
                                            let closeDate = form?.object(forKey: "fecha_cierre") as? String
                                            let observation = form?.object(forKey: "descripcion") as? String
                                            let openQuestionLabel = form?.object(forKey: "label_pregunta") as? String
                                            let totalQuestions = form?.object(forKey: "total_preguntas") as? String
                                            var totalQuestionsInt = 0
                                            if(totalQuestions != nil){
                                                totalQuestionsInt = Int(totalQuestions!)!
                                            }
                                            let sended = form?.object(forKey: "estado") as? String
                                            var sendedInt = 0
                                            if(sended != nil){
                                                sendedInt = Int(sended!)!
                                            }
                                            let es_obligatoria = form?.object(forKey: "es_obligatoria") as? String
                                            var es_obligatoriaInt = 0
                                            if(es_obligatoria != nil){
                                                es_obligatoriaInt = Int(es_obligatoria!)!
                                            }
                                            var isOpen = false
                                            var isObl = false
                                            
                                            if(es_obligatoriaInt == 1){
                                                isObl = true
                                            }
                                            if(sendedInt == 0){
                                                isOpen = true
                                            }
                                            
                                            //Create an Form object
                                            let formObj = Form(idInServer: id!, name: name!, closeDate: closeDate!, observations: observation!, openQuestionLabel: openQuestionLabel!, totalQuestions: totalQuestionsInt, sended: isOpen,openQuestionNeeded:isObl)
                                            //Insert it in the array
                                            self.forms.append(formObj)
                                        }
                                        self.formsTableView.reloadData()
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
    
    /*------------------------------------------------------------------------------------------------------------
     Table view stuff
     ------------------------------------------------------------------------------------------------------------*/
    /*
     Total of items in table view
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forms.count
    }
    
    /*
     Init the table view data cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Get cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormTableViewCell", for: indexPath) as! FormTableViewCell
        //Get form of cell
        let form = forms[indexPath.row]
        //Set the cell info
        if(form.sended){
            cell.labelStatus.text = "Cerrada"
            cell.labelStatus.textColor = UIColor(red:0.05, green:0.45, blue:0.95, alpha:1.0)
        }else{
            cell.labelStatus.text = "Abierta"
            cell.labelStatus.textColor = UIColor(red:1.00, green:0.62, blue:0.08, alpha:1.0)
        }
        cell.labelNameForm.text = form.name
        cell.labelCloseDate.text = form.closeDate
        cell.labelTotalQuestions.text = String(form.totalQuestions)
        
        return cell
    }
    
    /*
     When click on a cell - formToQuestionSegue
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:FormTableViewCell = tableView.cellForRow(at: indexPath)! as! FormTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
        cell.selectedBackgroundView = backgroundView
        
        selectedForm = forms[indexPath.row]
        if(!selectedForm.sended){
            performSegue(withIdentifier: "formToQuestionSegue", sender: self)
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

}
