//
//  CosmeticIngredients+CoreDataClass.swift
//  
//
//  Created by Nguyễn Đức Thọ on 8/18/21.
//
//

import Foundation
import CoreData

@objc(CosmeticIngredients)
public class CosmeticIngredients: NSManagedObject, Decodable {
    enum CodingKeys: String, CodingKey {
        case inci
        case descriptionvn = "descriptionVn"
        case descriptionen = "description"
        case categories1
        case categories2
        case categories3
        case rating
    }
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.inci = try container.decode(String.self, forKey: .inci)
        self.descriptionen = try container.decode(String.self, forKey: .descriptionen)
        self.descriptionvn = try container.decode(String.self, forKey: .descriptionvn)
        self.categories1 = try container.decode(String.self, forKey: .categories1)
        self.categories2 = try container.decode(String.self, forKey: .categories2)
        self.categories3 = try container.decode(String.self, forKey: .categories3)
        self.rating = try container.decode(String.self, forKey: .rating)
    }
}
