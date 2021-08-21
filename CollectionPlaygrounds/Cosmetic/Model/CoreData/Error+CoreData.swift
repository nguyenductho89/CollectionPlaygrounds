//
//  Error+.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/22/21.
//

import Foundation

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
