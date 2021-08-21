//
//  NSManagedObjectContext+Extension.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/22/21.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func saveResult() -> Result<Void, Error> {
        Result {try save()}
    }
}
