//
//  AppDelegate.swift
//  kickboardBookingAppProject
//
//  Created by 단예진 on 7/22/24.
//

import UIKit
import CoreData
import KakaoMapsSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SDKInitializer.InitSDK(appKey: "fee1b2fd7185bc9d8c9c433b337417a7")
        
        preloadKickboardData() // 킥보드 데이터 미리 저장
        
        return true
    }

    private func preloadKickboardData() {
        let kickboardCount = CoreDataHelper.shared.fetchAllKickboards().count
        guard kickboardCount == 0 else { return }
        
        let kickboards = [
            (id: "TL1485", latitude: 37.190159098980295, longitude: 127.02760813777273, battery: "40%", fee: "150원"),
            (id: "CI1480", latitude: 37.19763319911881, longitude: 127.03178416256846, battery: "1%", fee: "100원"),
            (id: "GX1230", latitude: 37.19222600470535, longitude: 127.02831125109035, battery: "50%", fee: "100원"),
            (id: "ZE1361", latitude: 37.195778081540524, longitude: 127.0267833891205, battery: "31%", fee: "200원"),
            (id: "QJ0831", latitude: 37.19426407105903, longitude: 127.03296812994411, battery: "98%", fee: "200원"),
            (id: "JV7002", latitude: 37.198317720379, longitude: 127.03212377940471, battery: "34%", fee: "100원"),
            (id: "XZ4121", latitude: 37.19622015358115, longitude: 127.03236718469942, battery: "46%", fee: "50원"),
            (id: "FD0215", latitude: 37.19277343059716, longitude: 127.02923154383885, battery: "59%", fee: "200원"),
            (id: "GQ8889", latitude: 37.19722228616542, longitude: 127.03022887525024, battery: "1%", fee: "200원"),
            (id: "UO8278", latitude: 37.1962730652396, longitude: 127.02699534687916, battery: "65%", fee: "150원")
        ]

        for kickboard in kickboards {
            CoreDataHelper.shared.saveKickboard(
                id: kickboard.id,
                latitude: kickboard.latitude,
                longitude: kickboard.longitude,
                battery: kickboard.battery,
                fee: kickboard.fee
            )
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "kickboardBookingAppProject")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

