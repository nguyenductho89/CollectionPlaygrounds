//
//  Array+CoreData.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/22/21.
//

import Foundation
import CoreData

extension Array where Element == JSONObject {
    enum ArrayJSONObjectImportError: Error {
        case arrayJSONObjectImportFailSome(_ errorIndexes:[Int])
        case arrayJSONObjectImportFailAll
        
        public var localizedDebugString: String? {
            switch self {
            case .arrayJSONObjectImportFailSome(let indexes):
                return NSLocalizedString("Import error in indexes: \(indexes.description)", comment: "ArrayJSONObjectImportError")
            default:
                return NSLocalizedString("All items in json file are not correct. Should check imported file or NSManagedObject keys", comment: "ArrayJSONObjectImportError")
            }
        }
        
    }
    func importToCoreData<T: DecoableNSManagedObject>(managedContext: NSManagedObjectContext, type: T.Type) -> Result<RecordImportedCount, Error> {
        let errorIndexes = self.map {$0.convertToManagedObject(managedContext: managedContext, type: type)}
            .enumerated()
            .filter({
                (try? $0.element.get()) == nil
            })
            .map {$0.offset}
        switch errorIndexes.count {
        case 0:
            return .success(self.count)
        case self.count:
            return .failure(ArrayJSONObjectImportError.arrayJSONObjectImportFailAll)
        default:
            return .failure(ArrayJSONObjectImportError.arrayJSONObjectImportFailSome(errorIndexes))
        }
    }
}

extension Array where Element == Result<DecoableNSManagedObject, Error> {
    func errorIndexes() -> [Int] {
        self.enumerated()
            .filter({
                (try? $0.element.get()) == nil
            })
            .map {$0.offset}
    }
}
