//
//  Error+.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/22/21.
//

import Foundation

enum ImportJSONToCoreDataError: Error {
    case bundeError(_ error: Bundle.BundleError)
    case jsonSerialization(_ error: JSONSerialization.JSONSerializationError)
    case importError(_ error: Array<JSONObject>.ArrayJSONObjectImportError)
    case systemError(_ error: Error)
}

extension Error {
    func importJSONDictArrayError() -> ImportJSONToCoreDataError {
        if let be = self as? Bundle.BundleError {
            return .bundeError(be)
        } else if let je = self as? JSONSerialization.JSONSerializationError {
            return .jsonSerialization(je)
        } else if let aje = self as? Array<JSONObject>.ArrayJSONObjectImportError {
            return .importError(aje)
        } else {
            return .systemError(self)
        }
    }
}
