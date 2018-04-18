//
//  SuccessViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    
    @IBOutlet weak var successText: UILabel!
    @IBOutlet weak var phraseText: UILabel!
    @IBOutlet var mainView: UIView!
    
    var successStr:String = ""
    var phraseStr:String = ""
    var isPasswordRecovery:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the params
        if(isPasswordRecovery){
            successStr = "Sus datos de acceso serán enviado al siguiente correo:"
        }else{
            phraseStr = Constants().getRandomPhrase()
            successStr = "Se ha enviado correctamente"
        }
        
        //Set the ui texts
        successText.text = successStr
        phraseText.text = phraseStr
        
        //When touch the screen
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.checkAction(sender:)))
        self.mainView.addGestureRecognizer(gesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Do something when touch the screen
     **/
    @objc func checkAction(sender : UITapGestureRecognizer) {
        
        if(isPasswordRecovery){
            //Go to login
            performSegue(withIdentifier: "successToLoginSegue", sender: self)
        }else{
            //Go to main menu
            performSegue(withIdentifier: "successToMainSegue", sender: self)
        }
        
    }

}
