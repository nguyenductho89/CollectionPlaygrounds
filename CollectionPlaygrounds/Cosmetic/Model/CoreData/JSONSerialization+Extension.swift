//
//  JSONSerialization+Extension.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/22/21.
//

import Foundation

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
