//
//  CoreDataHelper.swift
//  kickboardBookingAppProject
//
//  Created by t2023-m0019 on 7/26/24.
//

import CoreData
import UIKit

class CoreDataHelper {
    static let shared = CoreDataHelper()
    
    private init() {}
    
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createKickboard(id: String, latitude: Double, longitude: Double, battery: String, fee: String) {
        
        let entity = NSEntityDescription.entity(forEntityName: "ElecKick", in: context)!
        let kickboard = NSManagedObject(entity: entity, insertInto: context)
        kickboard.setValue(id, forKey: "id")
        kickboard.setValue(latitude, forKey: "latitude")
        kickboard.setValue(longitude, forKey: "longitude")
        kickboard.setValue(battery, forKey: "battery")
        kickboard.setValue(fee, forKey: "fee")
        saveContext()
    }
    
    func fetchKickboard(byLatitude latitude: Double, longitude: Double) -> Kickboard? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ElecKick")
        fetchRequest.predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", latitude, longitude)
        do {
            let kickboards = try context.fetch(fetchRequest)
            return kickboards.first as? Kickboard
        } catch {
            print("Failed to fetch kickboard: \(error)")
            return nil
        }
    }
}

