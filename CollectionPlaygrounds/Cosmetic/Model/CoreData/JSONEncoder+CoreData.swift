//
//  JSONEncoder+CoreData.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/22/21.
//

import Foundation
import CoreData

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}

extension JSONDecoder {
    func decodeDataToManagedObject<T: DecoableNSManagedObject>(data:Data,
                                                               managedContext: NSManagedObjectContext,
                                                               type: T.Type) -> Result<T,Error> {
        self.userInfo[CodingUserInfoKey.managedObjectContext] = managedContext
        return Result { try self.decode(type, from: data) }
    }
}
