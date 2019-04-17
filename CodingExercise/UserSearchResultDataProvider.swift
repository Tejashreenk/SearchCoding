//
//  UsernameSearchResultDataProvider.swift
//  CodingExercise
//
//  Copyright © 2018 slack. All rights reserved.
//

import Foundation

// MARK: - Interfaces
protocol UserSearchResultDataProviderInterface {
    /*
     * Fetches users from that match a given a search term
     */
    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (_ users:[UserSearchResult], _ error: Error?) -> Void)
}

class UserSearchResultDataProvider: UserSearchResultDataProviderInterface {
    var slackAPI: SlackAPIInterface

    init(slackAPI: SlackAPIInterface) {
        self.slackAPI = slackAPI
    }

    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (_ users:[UserSearchResult], _ error: Error?) -> Void) {
        self.slackAPI.fetchUsers(searchTerm) { users,error in
            completionHandler(users,error)
        }
    }
}
