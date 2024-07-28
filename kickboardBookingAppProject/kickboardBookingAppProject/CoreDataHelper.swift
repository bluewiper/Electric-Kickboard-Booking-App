import CoreData

class CoreDataHelper {
    static let shared = CoreDataHelper()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Kickboard") // 여기에 실제 모델 이름을 입력하세요.
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveKickboard(id: String, latitude: Double, longitude: Double, battery: String, fee: String) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Entity", in: context) else {
            print("Failed to find entity description for 'Kickboard'")
            return
        }
        let kickboard = NSManagedObject(entity: entity, insertInto: context)
        
        kickboard.setValue(id, forKey: "id")
        kickboard.setValue(latitude, forKey: "latitude")
        kickboard.setValue(longitude, forKey: "longitude")
        kickboard.setValue(battery, forKey: "battery")
        kickboard.setValue(fee, forKey: "fee")

        do {
            try context.save()
        } catch {
            print("Failed to save kickboard: \(error)")
        }
    }

    func fetchAllKickboards() -> [Entity] {
        let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
        
        do {
            let kickboards = try context.fetch(fetchRequest)
            return kickboards
        } catch {
            print("Failed to fetch kickboards: \(error)")
            return []
        }
    }
}
