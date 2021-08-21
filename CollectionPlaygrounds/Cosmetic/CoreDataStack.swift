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
    
    func importJSONDictArray<T: DecoableNSManagedObject>(type: T.Type,
                                                         forResource: String,
                                                         witExtension: String) -> Result<RecordImportedCount, Error> {
        return Bundle.main.urlResult(forResource: forResource, withExtension: witExtension)
            //data from url
            .flatMap {$0.dataResult()}
            //array json object
            .flatMap {JSONSerialization.arrayJsonObjectResult(with: $0, options: [.fragmentsAllowed])}
            //import to CoreData -> number of successfully imported records
            .flatMap {$0.importToCoreData(managedContext: self.managedContext, type: type)}
    }
}

extension Error {
    func importJSONDictArrayError(bundeError: ((Bundle.BundleError) -> Void)?,
                                  jsonSerialization: ((JSONSerialization.JSONSerializationError) -> Void)?,
                                  importError: ((Array<JSONObject>.ArrayJSONObjectImportError) -> Void)?,
                                  systemError: ((Error) -> Void)?) {
        if let be = self as? Bundle.BundleError {
            bundeError?(be)
        } else if let je = self as? JSONSerialization.JSONSerializationError {
            jsonSerialization?(je)
        } else if let aje = self as? Array<JSONObject>.ArrayJSONObjectImportError {
            importError?(aje)
        } else {
            systemError?(self)
        }
    }
}

typealias RecordImportedCount = Int
typealias JSONObject = [String:Any]
public typealias DecoableNSManagedObject = NSManagedObject & Decodable
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
        let errorIndexes = self.map {$0.importToCoreData(managedContext: managedContext, type: type)}
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

extension JSONObject {
    func importToCoreData<T: DecoableNSManagedObject>(managedContext: NSManagedObjectContext, type: T.Type) -> Result<T,Error> {
        JSONSerialization.dataResult(withJSONObject: self, options: [.prettyPrinted])
            .flatMap {JSONDecoder().decodeDataToManagedObject(data: $0, managedContext: managedContext, type: type)}
    }
}

extension JSONDecoder {
    func decodeDataToManagedObject<T: DecoableNSManagedObject>(data:Data,
                                                               managedContext: NSManagedObjectContext,
                                                               type: T.Type) -> Result<T,Error> {
        self.userInfo[CodingUserInfoKey.managedObjectContext] = managedContext
        return Result { try self.decode(type, from: data) }
    }
}

extension Bundle {
    
    enum BundleError: Error {
        case resourceNotFound
    }
    
    func urlResult(forResource: String, withExtension: String) -> Result<URL, Error> {
        guard let url = self.url(forResource: forResource, withExtension: withExtension) else {
            return .failure(BundleError.resourceNotFound)
        }
        return .success(url)
    }
}

extension URL {
    func dataResult() -> Result<Data, Error> {
        return Result {try Data(contentsOf: self)}
    }
}

extension JSONSerialization {
    enum JSONSerializationError: Error {
        case unableParseData
    }
    class func arrayJsonObjectResult(with data: Data,
                                options opt: JSONSerialization.ReadingOptions = []) -> Result<[JSONObject], Error> {
            guard let dict = try? jsonObject(with: data, options: opt) as? [JSONObject] else {
                return .failure(JSONSerializationError.unableParseData)
            }
        return .success(dict)
    }
    
    class func dataResult(withJSONObject obj: Any, options opt: JSONSerialization.WritingOptions = []) -> Result<Data, Error> {
        return Result {try JSONSerialization.data(withJSONObject: obj, options: opt)}
    }
}

extension NSManagedObjectContext {
    func saveResult() -> Result<Void, Error> {
        Result {try save()}
    }
}
