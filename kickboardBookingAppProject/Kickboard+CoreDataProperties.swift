//
//  Kickboard+CoreDataProperties.swift
//  kickboardBookingAppProject
//
//  Created by t2023-m0019 on 7/26/24.
//
//

import Foundation
import CoreData


extension Kickboard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Kickboard> {
        return NSFetchRequest<Kickboard>(entityName: "Kickboard")
    }

    @NSManaged public var battery: String?
    @NSManaged public var fee: String?
    @NSManaged public var id: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

extension Kickboard : Identifiable {

}
