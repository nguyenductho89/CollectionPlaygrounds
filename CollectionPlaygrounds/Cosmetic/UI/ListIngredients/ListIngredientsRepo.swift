//
//  ListIngredientsRepo.swift
//  Cosmetic
//
//  Created by Nguyễn Đức Thọ on 8/27/21.
//

import Foundation
protocol ListIngredientsRepoProtocol {
    
}

class ListIngredientsRepoImpl: ListIngredientsRepoProtocol {
    var webService: WebService!
    var dao = CoreDataStack(modelName: "Cosmetic")
}
