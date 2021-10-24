//
//  UserDataManager.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 24/10/2021.
//

import Foundation
import CoreData
import UIKit

open class DataManager: NSObject {
    
    public static let sharedInstance = DataManager()
    
    private override init() {}

    // Helper func for getting the current context.
    private func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }

    func retrieveUser() -> NSManagedObject? {
        guard let managedContext = getContext() else { return nil }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if result.count > 0 {
                // Assuming there will only ever be one User in the app.
                return result[0]
            } else {
                return nil
            }
        } catch let error as NSError {
            print("Retrieving user failed. \(error): \(error.userInfo)")
           return nil
        }
    }

    func saveBook(_ user: User) {
        print(NSStringFromClass(type(of: user)))
        guard let managedContext = getContext() else { return }
        guard let user = retrieveUser() else { return }
        user.setValue(user, forKey: "User")
        do {
            print("Saving session...")
            try managedContext.save()
        } catch let error as NSError {
            print("Failed to save session data! \(error): \(error.userInfo)")
        }
    }

}
