//
//  ErrorViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {
    
    @IBOutlet weak var errorText: UILabel!
    @IBOutlet var mainView: UIView!
    
    var errorStr:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the ui texts
        errorText.text = errorStr
        
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
        
        //Close this view
        self.dismiss(animated: true, completion: nil) //Remove this
    }
}
