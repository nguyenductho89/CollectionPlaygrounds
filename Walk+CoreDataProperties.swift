//
//  Walk+CoreDataProperties.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/8/21.
//
//

import Foundation
import CoreData


extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }

    @NSManaged public var date: Date?
    @NSManaged public var person: Person?

}

extension Walk : Identifiable {

}
