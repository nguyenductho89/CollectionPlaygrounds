//
//  URL+Extension.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/22/21.
//

import Foundation

extension URL {
    func dataResult() -> Result<Data, Error> {
        return Result {try Data(contentsOf: self)}
    }
}
