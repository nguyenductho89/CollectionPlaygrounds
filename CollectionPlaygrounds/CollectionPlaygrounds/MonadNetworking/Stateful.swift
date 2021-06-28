//
//  Stateful.swift
//  MonadNetworking
//
//  Created by Nguyễn Đức Thọ on 6/28/21.
//

import Foundation

class Stateful: SocialService {
    func followerStats(u: String, c: NSCache<NSString, FollowerStats>) -> (cache: NSCache<NSString, FollowerStats>, followerStats: FollowerStats) {
        let (c1, ofs) = checkCache(u: u, c: c)
        switch ofs {
        case .some(let fs):
            return (c1,fs)
        case .none:
            return retrieve(u: u, c: c1)
        }
        
    }
    
    func checkCache(u: String,
                    c: NSCache<NSString, FollowerStats>) -> (cache: NSCache<NSString, FollowerStats>,
                                                          followerStats: FollowerStats?) {
        return (c, c.object(forKey: NSString(string: u)))
    }
    
    func retrieve(u: String,
                  c: NSCache<NSString, FollowerStats>) -> (cache: NSCache<NSString, FollowerStats>,
                                                        followerStats: FollowerStats) {
        let fs = FollowerStats()
        fs.numFollowers = 10
        fs.numFollowing = 12
        fs.userName = "cacheusername"
        c.setObject(fs, forKey: NSString(string: u))
        return (c, fs)
    }
}
