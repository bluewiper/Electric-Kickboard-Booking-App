//
//  Entity+CoreDataProperties.swift
//  kickboardBookingAppProject
//
//  Created by t2023-m0019 on 7/26/24.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var id: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var battery: String?
    @NSManaged public var fee: String?

}

extension Entity : Identifiable {

}
