//
//  CampaignViewController.swift
//  Moods
//
//  Created by Santiago Moreno on 4/01/18.
//  Copyright © 2018 Tiago Moreno. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class CampaignViewController: UIViewController {
    
    @IBOutlet weak var imgCampaign: UIImageView!
    
    var controller:NSFetchedResultsController<UsserSession>!
    var userId = ""
    var errorMessage = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        attemptFetch()
        //Get the id of the loged user
        attemptFetch()
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
        loadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     Load the image to show
     */
    func loadImage(){
        //Create the JSON to send
        let parameters: Parameters = [
            "idusuario": userId,
            ]
        //Send info to the server and verify
        Alamofire.request(Constants.GET_CAMPAIGN_URL,
                          method: .post,
                          parameters:parameters,
                          encoding: JSONEncoding.default).responseJSON { response in
                            
                            //Json response parse
                            if let json:NSDictionary = response.result.value as? NSDictionary {
                                //Get values from response
                                let ans:Int = json.object(forKey: "ans") as! Int
                                let body = json.object(forKey: "body") as? NSDictionary
                                self.errorMessage = json.object(forKey: "error") as! String
                                
                                if(ans == 1){
                                    //Get the Events
                                    if(body != nil){
                                        let base64 = body?.object(forKey: "image_base64") as? String
                                        print("\(body)")
                                        print("b64 \(base64)")
                                        if(base64 != nil){
                                            print("base 64: \(base64)")
                                            if let decodedData = Data(base64Encoded: base64!, options: .ignoreUnknownCharacters) {
                                                print("base 64: in)")
                                                let image = UIImage(data: decodedData)
                                                self.imgCampaign.image = image
                                            }
                                        }
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
    /*
     Prepare the info to send in the segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? ErrorViewController {
            viewControllerB.errorStr = errorMessage
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
