//
//  UsserSession+CoreDataProperties.swift
//  
//
//  Created by Santiago Moreno on 10/01/18.
//
//

import Foundation
import CoreData


extension UsserSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UsserSession> {
        return NSFetchRequest<UsserSession>(entityName: "UsserSession")
    }

    @NSManaged public var id_server: String?
    @NSManaged public var name: String?
    @NSManaged public var username: String?
    @NSManaged public var mail: String?
    @NSManaged public var phone: String?
    @NSManaged public var password: String?
    @NSManaged public var rol_id: String?

}
