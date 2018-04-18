//
//  Parameters+CoreDataProperties.swift
//  
//
//  Created by Santiago Moreno on 10/01/18.
//
//

import Foundation
import CoreData


extension Parameters {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Parameters> {
        return NSFetchRequest<Parameters>(entityName: "Parameters")
    }

    @NSManaged public var start_hour: String?
    @NSManaged public var end_hour: String?
    @NSManaged public var laboral_days: String?
    @NSManaged public var threshold: Double

}
