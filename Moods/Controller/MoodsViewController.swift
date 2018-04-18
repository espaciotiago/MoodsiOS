//
//  MoodsViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 3/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit

class MoodsViewController: UIViewController {
    
    var selectedMood:String = ""
    var selectedMoodId:String = ""
    var selectedMoodValue:Int = 0
    let cont = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? EventViewController {
            viewControllerB.mood = self.selectedMood
            viewControllerB.moodId = self.selectedMoodId
            viewControllerB.moodValue = self.selectedMoodValue
        }
    }
    
    /**
     Actions
     **/
    @IBAction func onClickMood1(_ sender: Any) {
        self.selectedMoodId = "mood_1"
        self.selectedMood = "Muy bien"
        self.selectedMoodValue = 5
        shouldPerformSegue(withIdentifier: "mood1Segue", sender: self)
    }
    
    @IBAction func onClickMood2(_ sender: Any) {
        self.selectedMoodId = "mood_2"
        self.selectedMood = "Bien"
        self.selectedMoodValue = 4
        shouldPerformSegue(withIdentifier: "mood2Segue", sender: self)
    }
    
    @IBAction func onClickMood3(_ sender: Any) {
        self.selectedMoodId = "mood_3"
        self.selectedMood = "No tan bien"
        self.selectedMoodValue = 2
        shouldPerformSegue(withIdentifier: "mood3Segue", sender: self)
    }
    
    @IBAction func onClickMood4(_ sender: Any) {
        self.selectedMoodId = "mood_4"
        self.selectedMood = "Mal"
        self.selectedMoodValue = 1
        shouldPerformSegue(withIdentifier: "mood4Segue", sender: self)
    }
    
    @IBAction func onClickMood5(_ sender: Any) {
        print("mood 5");
        self.selectedMoodId = "mood_5"
        self.selectedMood = "Indiferente"
        self.selectedMoodValue = 3
        performSegue(withIdentifier: "mood4Segue", sender: self)
    }
    
    
    
    /**
     Do perfome segue?
     **/
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if(cont){
            return true
        }else{
            return false
        }
    }
    
}
