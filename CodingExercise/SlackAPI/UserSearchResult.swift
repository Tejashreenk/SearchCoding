//
//  UserSearchResult.swift
//  CodingExercise
//
//  Copyright © 2018 slack. All rights reserved.
//

import Foundation

struct UserSearchResult: Codable {
    let avatar_url: String
    let display_name: String
    let id: Int
    let username: String
}

struct SearchResponse: Codable {
    let ok: Bool
    let error: String?
    let users: [UserSearchResult]
}

enum projectError:Error {
    
    case isEmpty
    case isInBlackList
    case addToBlacklist
    case offline
}

func errorMessage(passedEnum:projectError) -> (String) {
    let title : String!
    
    switch passedEnum {
    case .isEmpty:
        title = "Text Field Should not be Empty"
    case .isInBlackList:
        title = "Username typed has a Blacklist prefix"
    case .addToBlacklist:
        title = "Username typed is added to the Blacklist"
    case .offline:
        title = "Please connect to Internet Connection"
    default:
        title = "Some Error"
    }
    
    return title
}
