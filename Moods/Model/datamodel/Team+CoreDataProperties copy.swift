//
//  Team+CoreDataProperties.swift
//  
//
//  Created by Santiago Moreno on 10/01/18.
//
//

import Foundation
import CoreData


extension Team {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    @NSManaged public var name: String?
    @NSManaged public var team_id: String?

}
