//
//  Bundle+CoreData.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/22/21.
//

import Foundation

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
