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
    
    func createUser(_ user: User) {
        print(NSStringFromClass(type(of: user)))
        guard let managedContext = getContext() else { return }
        let userData = NSManagedObject(entity: userEntity, insertInto: managedContext)
        userData.setValue(user.id, forKey: "id")
        userData.setValue(user.name, forKey: "name")
        userData.setValue(user.age, forKey: "age")
        userData.setValue(user.city, forKey: "city")
        userData.setValue(user.occupation, forKey: "occupation")
        userData.setValue(user.hasFlat, forKey: "hasFlat")
        userData.setValue(user.isMale, forKey: "isMale")
        userData.setValue(user.matchedUsers, forKey: "matchedUsers")
        userData.setValue(user.registeredDate, forKey: "registeredDate")
        userData.setValue(user.description, forKey: "userDescription")
        do {
            print("Saving session...")
            try managedContext.save()
        } catch let error as NSError {
            print("Failed to save session data! \(error): \(error.userInfo)")
        }
    }

    func retrieveUser() -> NSManagedObject? {
        guard let managedContext = getContext() else { return nil }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        
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
    
    func updateUser(key: String, value: Any) {
        guard let managedContext = getContext() else { return }
        guard let userData = retrieveUser() else { return }
        userData.setValue(value, forKey: key)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Failed to save new user! \(error): \(error.userInfo)")
        }
    }
    
    func deleteUser() {
        guard let managedContext = getContext() else { return }
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "UserData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError {
            print("Failed to delete user! \(error): \(error.userInfo)")
        }
        
    }
    
    private lazy var userEntity: NSEntityDescription = {
        let managedContext = getContext()
        return NSEntityDescription.entity(forEntityName: "UserData", in: managedContext!)!
    }()
    
    var isEmpty: Bool {
        guard let managedContext = getContext() else { return true }
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
            let count  = try managedContext.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
}
