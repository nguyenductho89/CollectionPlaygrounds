//
//  ListIngredientsCD.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/28/21.
//

import Foundation
import CoreData

class ListIngredientsCD {
    lazy var coreDataStack = CoreDataStack(modelName: "Cosmetic")
    lazy var fetchedResultsController: NSFetchedResultsController<CosmeticIngredients> = {
    // 1
    let fetchRequest: NSFetchRequest<Team> = CosmeticIngredients.fetchRequest()
    // 2
    let fetchedResultsController = NSFetchedResultsController( fetchRequest: fetchRequest,
                                                               managedObjectContext: coreDataStack.managedContext,
                                                               sectionNameKeyPath: nil,
                                                               cacheName: nil)
        let sort = NSSortDescriptor( key: #keyPath(CosmeticIngredients.inci), ascending: true)
       fetchRequest.sortDescriptors = [sort]
      return fetchedResultsController
    }()
    
    func fetch() {
        do {
        try fetchedResultsController.performFetch()
        } catch let error as NSError {
        print("Fetching error: \(error), \(error.userInfo)") }
    }
}
