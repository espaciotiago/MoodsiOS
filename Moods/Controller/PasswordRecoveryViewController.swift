//
//  PasswordRecoveryViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit

class PasswordRecoveryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onClickPassRecovery(_ sender: Any) {
        performSegue(withIdentifier: "forgotToSuccess", sender: self)
    }
    
    /*
     Do the segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? SuccessViewController {
            viewControllerB.isPasswordRecovery = true
            viewControllerB.phraseStr = "admin@ufomobile.com"
        }
    }

}
