//
//  CoreDataManager.swift
//  FitnessApp
//
//  Created by Ilnur on 13.11.2025.
//

import Foundation
import CoreData
import UIKit

protocol CoreDataManagerProtocol {
    func save()
    func delete(_ object: NSManagedObject)
    func create<T: NSManagedObject>(_ type: T.Type) -> T
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) throws -> [T]
}

final class CoreDataManager: CoreDataManagerProtocol {
    static let shared = CoreDataManager()
    
    private lazy var context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    
    func create<T: NSManagedObject>(_ type: T.Type) -> T {
        let entityName = String(describing: type)
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! T
    }
    
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) throws -> [T] {
        return try context.fetch(request)
    }
}
