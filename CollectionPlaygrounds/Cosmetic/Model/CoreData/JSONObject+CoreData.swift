//
//  JSONObject+CoreData.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/22/21.
//

import Foundation
import CoreData

extension JSONObject {
    func importToCoreData<T: DecoableNSManagedObject>(managedContext: NSManagedObjectContext, type: T.Type) -> Result<T,Error> {
        JSONSerialization.dataResult(withJSONObject: self, options: [.prettyPrinted])
            .flatMap {JSONDecoder().decodeDataToManagedObject(data: $0, managedContext: managedContext, type: type)}
    }
}
