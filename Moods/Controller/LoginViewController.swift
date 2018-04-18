//
//  ViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 3/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    var errorMessage:String = ""
    var userId:String = ""
    var isLeader:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewResizerOnKeyboardShown()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViewResizerOnKeyboardShown() {
        NotificationCenter.default.addObserver(self,selector: #selector(LoginViewController.keyboardWillShowForResizing),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(LoginViewController.keyboardWillHideForResizing),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    @objc func keyboardWillShowForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }
    
    @objc func keyboardWillHideForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
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

    /**
     Click on Login button
     **/
    @IBAction func onClickLogin(_ sender: Any) {
        let username = textFieldUsername.text
        let password = textFieldPassword.text
        // Verify the inputs and send the login to server
        if((username?.isEmpty)! || (password?.isEmpty)!){
            //Show error
            showAlert(title: "Información incompleta", message: "Por favor llene todos los campos para continuar")
        }else{
            //Create the JSON to send
            let parameters: Parameters = [
                "usuario": username ?? "",
                "contrasena": password ?? ""
            ]
            //Send info to the server and verify
            Alamofire.request(Constants.LOGIN_URL,
                              method: .post,
                              parameters:parameters,
                              encoding: JSONEncoding.default).responseJSON { response in
                                
                                //Json response parse
                                if let json:NSDictionary = response.result.value as? NSDictionary {
                                    //Get values from response
                                    print("JSON \(json)")
                                    let ans:Int = json.object(forKey: "ans") as! Int
                                    let body = (json.object(forKey: "body") as? NSDictionary)
                                    self.errorMessage = json.object(forKey: "error") as! String
                                    
                                    if(ans == 1){
                                        // Save the info in DB
                                        if(body != nil){
                                            let mail = body?.object(forKey: "correo") as! String
                                            let name = body?.object(forKey: "nombre") as! String
                                            self.userId = body?.object(forKey: "idusuario") as! String
                                            let username = body?.object(forKey: "usuario") as! String
                                            let cia = body?.object(forKey: "fk_id_compania") as! String
                                            let phone = body?.object(forKey: "telefono") as! String
                                            let rolId = body?.object(forKey: "fk_id_rol") as! String
                                            let password = body?.object(forKey: "contrasena") as! String
                                            let position = body?.object(forKey: "cargo") as! String
                                            if(rolId=="rol_1"){
                                                self.isLeader = false
                                            }else{
                                                self.isLeader = true
                                            }
                                            let user = UsserSession(context: context)
                                            user.id_server = self.userId
                                            user.mail = mail
                                            user.name = name
                                            user.cia = cia
                                            user.password = password
                                            user.phone = phone
                                            user.rol_id = rolId
                                            user.position = position
                                            user.username = username
                                            // Save the context of db
                                            ad.saveContext()
                                            //Go to loading
                                            self.performSegue(withIdentifier: "LoginToLoadingSegue", sender: self)
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
        
    }

    /*
     Prepare the segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? ErrorViewController {
            viewControllerB.errorStr = self.errorMessage
        }else if let viewControllerB = segue.destination as? LoadingViewController {
            viewControllerB.isUserLoged = true
            viewControllerB.isLeader = self.isLeader
            viewControllerB.userId = self.userId
        }
    }
}

