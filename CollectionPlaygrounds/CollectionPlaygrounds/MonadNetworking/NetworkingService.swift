//
//  NetworkingService.swift
//  MonadNetworking
//
//  Created by Nguyễn Đức Thọ on 6/28/21.
//

import Foundation

class FollowerStats {
    var userName: String = ""
    var numFollowers: Int = 0
    var numFollowing: Int = 0
}

protocol SocialService {
    func followerStats(u: String, c: NSCache<NSString, FollowerStats>) -> (cache: NSCache<NSString, FollowerStats>, followerStats: FollowerStats)
}

extension FollowerStats {
    static var className: NSString {
        return NSString(string: String(describing: Self.self))
    }
}
