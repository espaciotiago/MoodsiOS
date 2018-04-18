//
//  QuestionsViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import Alamofire
class QuestionsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var labelFormTitle: UILabel!
    @IBOutlet weak var tableViewQuestions: UITableView!
    @IBOutlet weak var textViewOpenQuestion: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPreview: UIButton!
    
    var checkedRows=Set<NSIndexPath>()
    
    var form:Form!
    var questions = [FormQuestion]()
    var questionsPage = [FormQuestion]()
    var options = [FormOption]()
    var totalPages:Int!
    var actualPage:Int!
    var errorMessage:String = ""
    var userId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the info
        labelFormTitle.text = form.name
        textViewOpenQuestion.placeholder = form.openQuestionLabel
        textViewOpenQuestion.isHidden = true
        //Load the questions and the options
        loadQuestions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
     Action: Click on next button
     */
    @IBAction func onClickNext(_ sender: Any) {
        if(actualPage==totalPages){
            //Ready to send
            //Set the buttons params
            //Verify complete
            var readyToSend = true
            var error = ""
            let idOpenNeeded = form.openQuestionNeeded
            let openQuestionResponse = textViewOpenQuestion.text
            for i in 0..<questions.count{
                let question = questions[i]
                if(question.selectedOption.idInServer == nil || question.selectedOption.idInServer.isEmpty){
                    //Do something
                    readyToSend = false
                    error = "Debe responder todas las preguntas para continuar"
                    break
                }
            }
            
            if(idOpenNeeded && (openQuestionResponse?.isEmpty)!){
                readyToSend = false
                error = "La pregunta abierta es obligatoria"
            }
            
            if(readyToSend){
                if((openQuestionResponse?.isEmpty)!){
                    form.observations = ""
                }else{
                    form.observations = openQuestionResponse!
                }
                // Send the form
                sendForm()
            }else{
                showAlert(title: "Encuesta incompleta", message: error)
            }
        }else{
            paginateList()
            tableViewQuestions.reloadData()
        }
    }
    /*
     Action: Click on preview
     */
    @IBAction func onClickPreview(_ sender: Any) {
        textViewOpenQuestion.isHidden = true
        actualPage = actualPage - 2
        paginateList()
        tableViewQuestions.reloadData()
    }
    /*
     Get the questions of the actual page
     */
    func paginateList(){
        if(actualPage<totalPages){
            actualPage = actualPage + 1
            if(actualPage==1){
                if(questions.count < Constants.FORM_PAGINATION){
                    questionsPage = questions
                }else{
                    questionsPage = Array(questions[0..<Constants.FORM_PAGINATION * actualPage])
                }
            }else if(actualPage == totalPages){
                questionsPage = Array(questions[(Constants.FORM_PAGINATION * actualPage) - Constants.FORM_PAGINATION..<questions.count])
            }else{
                questionsPage = Array(questions[(Constants.FORM_PAGINATION * actualPage) - Constants.FORM_PAGINATION..<Constants.FORM_PAGINATION * actualPage])
            }
        }
        //Is the first page
        if (actualPage==1){
            btnPreview.isEnabled = false
        }else{
            btnPreview.isEnabled = true
        }
        //Is the last page
        if (actualPage==totalPages){
            textViewOpenQuestion.isHidden = false
            btnNext.setTitle("ENVIAR", for: .normal)
        }else{
            btnNext.setTitle("SIGUIENTE", for: .normal)
        }
    }
    
    /*
     Load the questions and the answer options from the server
     */
    func loadQuestions(){
        //Create the JSON to send
        let parameters: Parameters = [
            "idusuario": userId,
            "idencuesta":form.idInServer
            ]
        //Send info to the server and verify
        Alamofire.request(Constants.GET_QUESTIONS_URL,
                          method: .post,
                          parameters:parameters,
                          encoding: JSONEncoding.default).responseJSON { response in
                            
                            //Json response parse
                            if let json:NSDictionary = response.result.value as? NSDictionary {
                                print("JSON: \(json)")
                                //Get values from response
                                let ans:Int = json.object(forKey: "ans") as! Int
                                let body = json.object(forKey: "body") as? NSDictionary
                                self.errorMessage = json.object(forKey: "error") as! String
                                
                                if(ans == 1){
                                    //Get the forms
                                    if(body != nil){
                                        let preguntas = body?.object(forKey: "preguntas") as? NSArray
                                        let opciones_respuestas = body?.object(forKey: "opciones_respuestas") as? NSArray
                                        //Get the questions
                                        if(preguntas != nil){
                                            for i in 0..<preguntas!.count{
                                                let pregunta = preguntas![i] as? NSDictionary
                                                if(pregunta != nil){
                                                    let idInServer = pregunta?.object(forKey: "idencuesta_pregunta") as? String
                                                    let headerText = pregunta?.object(forKey: "texto_pregunta") as? String
                                                    let category = pregunta?.object(forKey: "categoria") as? String
                                                    let formQ = FormQuestion(idInServer: idInServer!, category: category!, headerText: headerText!)
                                                    self.questions.append(formQ)
                                                }
                                            }
                                        }
                                        //Get the options
                                        if(opciones_respuestas != nil){
                                            for i in 0..<opciones_respuestas!.count{
                                                let opcion = opciones_respuestas![i] as? NSDictionary
                                                if(opcion != nil){
                                                    let idInServer = opcion?.object(forKey: "idencuesta_opcion") as? String
                                                    let label = opcion?.object(forKey: "label") as? String
                                                    let value = opcion?.object(forKey: "valor") as? String
                                                    var valueInt = 0
                                                    if(value != nil){
                                                        valueInt = Int(value!)!
                                                    }
                                                    let formO = FormOption(idInServer: idInServer!, label: label!, checked: false, value: valueInt)
                                                    self.options.append(formO)
                                                }
                                            }
                                        }
                                    }
                                    //Get the total of pages
                                    self.totalPages = Int(self.questions.count/Constants.FORM_PAGINATION)
                                    self.actualPage = 0
                                    let res = self.questions.count % Constants.FORM_PAGINATION
                                    if(res > 0){
                                        self.totalPages = self.totalPages + 1
                                    }
                                    self.paginateList()
                                    //Reset tableview
                                    self.tableViewQuestions.reloadData()
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
     Send the form  to the server
     */
    func sendForm(){
        var arrayOfDict = [Dictionary<String,String>]()
        for i in 0..<questions.count{
            let question = questions[i]
            var dict = Dictionary<String, String>()
            if(question.selectedOption.idInServer != nil && !question.selectedOption.idInServer.isEmpty){
                dict.updateValue(question.idInServer, forKey: "idpregunta")
                dict.updateValue(question.selectedOption.idInServer, forKey: "idopcion")
                dict.updateValue("1", forKey: "valor")
                arrayOfDict.append(dict)
            }
        }
        //Create the JSON to send
        let parameters: Parameters = [
            "idusuario": userId,
            "idencuesta":form.idInServer,
            "respuesta_abierta": form.observations,
            "respuestas":arrayOfDict
        ]
        print("Parameters to send: \(parameters)")
        //Send info to the server and verify
        Alamofire.request(Constants.SEND_FORM_URL,
                          method: .post,
                          parameters:parameters,
                          encoding: JSONEncoding.default).responseJSON { response in
                            
                            //Json response parse
                            if let json:NSDictionary = response.result.value as? NSDictionary {
                                print("JSON: \(json)")
                                //Get values from response
                                let ans:Int = json.object(forKey: "ans") as! Int
                                let body = json.object(forKey: "body") as? NSDictionary
                                self.errorMessage = json.object(forKey: "error") as! String
                                
                                if(ans == 1){
                                    //Get the response
                                    self.performSegue(withIdentifier: "toSuccessSegue", sender: self)
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
    
    /*------------------------------------------------------------------------------------------------------------
     Table view stuff
     ------------------------------------------------------------------------------------------------------------*/
    /*
     Total of items in table view
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsPage.count
    }
    /*
     Init the table view data cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Get the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableViewCell", for: indexPath) as!QuestionTableViewCell
        //Get the question
        let question = questionsPage[indexPath.row]
        //Set the info
        let index = (actualPage-1)*Constants.FORM_PAGINATION + indexPath.row+1;
        cell.labelQuestion.text = "\(index). " + question.headerText
        cell.options = options
        cell.question = question
        cell.indexQuestion = indexPath.row
        for i in 0..<options.count{
            let opt = options[i]
            if(i==0){
                cell.btnOption1.setTitle(opt.label, for: .normal)
            }else if(i==1){
                cell.btnOption2.setTitle(opt.label, for: .normal)
            }else if(i==2){
                cell.btnOption3.setTitle(opt.label, for: .normal)
            }else if(i==3){
                cell.btnOption4.setTitle(opt.label, for: .normal)
            }else if(i==4){
                cell.btnOption5.setTitle(opt.label, for: .normal)
            }
        }
        return cell
    }
    
    /*
     When click on a cell
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:QuestionTableViewCell = tableView.cellForRow(at: indexPath)! as! QuestionTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
        cell.selectedBackgroundView = backgroundView
    }
}
