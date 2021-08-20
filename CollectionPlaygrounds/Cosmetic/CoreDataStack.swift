//
//  CoreDataStack.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/8/21.
//

import Foundation
import CoreData

class CoreDataStack {
    private let modelName: String
    
    lazy var managedContext: NSManagedObjectContext = { return self.storeContainer.viewContext
    }()
    
    init(modelName: String) {
        self.modelName = modelName }
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)") }
        }
        return container
    }()
    
    func saveContext () {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)") }
    }
    
    func importJSONSeedData() -> Result<Void, Error> {
        guard let jsonURL = Bundle.main.url(forResource: "ingredientsCosmetic", withExtension: "json") else {
            return .failure(CoreDataImportJSONError.resourceNotFound)
        }
        let jsonData = Result {try Data(contentsOf: jsonURL)}
            .flatMap { data in
                Result {try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [[String: Any]]}
            }
        guard let jsonArray = try? jsonData.get()  else {
            return .failure(CoreDataImportJSONError.fileDataInvalid)
        }
        
        jsonArray.forEach({ data in
            guard let data = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {
                return
            }
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.managedObjectContext] = self.managedContext
            guard let ingreParsed = try? decoder.decode(CosmeticIngredients.self, from: data) else {
                return
            }
            let ingre = CosmeticIngredients(context: self.managedContext)
            ingre.inci = ingreParsed.inci
            ingre.descriptionvn = ingreParsed.descriptionvn
            ingre.descriptionen = ingreParsed.descriptionen
            ingre.categories1 = ingreParsed.categories1
            ingre.categories2 = ingreParsed.categories2
            ingre.categories3 = ingreParsed.categories3
            ingre.rating = ingreParsed.rating
        })
        self.saveContext()
        return Result.success({}())
    }
}

enum CoreDataImportJSONError: Error {
    case resourceNotFound
    case fileDataInvalid
}
