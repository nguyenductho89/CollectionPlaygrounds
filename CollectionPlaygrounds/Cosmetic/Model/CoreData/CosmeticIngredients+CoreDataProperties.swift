//
//  CosmeticIngredients+CoreDataProperties.swift
//  
//
//  Created by Nguyễn Đức Thọ on 8/18/21.
//
//

import Foundation
import CoreData


extension CosmeticIngredients {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CosmeticIngredients> {
        return NSFetchRequest<CosmeticIngredients>(entityName: "CosmeticIngredients")
    }

    @NSManaged public var inci: String?
    @NSManaged public var descriptionvn: String?
    @NSManaged public var descriptionen: String?
    @NSManaged public var categories1: String?
    @NSManaged public var categories2: String?
    @NSManaged public var categories3: String?
    @NSManaged public var rating: String?

}
