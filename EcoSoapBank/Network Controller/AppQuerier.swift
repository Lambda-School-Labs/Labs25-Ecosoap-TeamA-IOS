//
//  AppQuerier.swift
//  EcoSoapBank
//
//  Created by Jon Bash on 2020-08-20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import Foundation
import OktaAuth


typealias NetworkCompletion<T> = (Result<T, Error>) -> Void


enum AppQueryError: Error {
    case noToken
    case other(Error)
    case unimplemented
    case unknown
}


class AppQuerier {
    private var token: String?
    private var networkService: GraphQLController

    private let oktaAuth = OktaAuth(
        baseURL: URL(string: "https://auth.lambdalabs.dev/")!,
        clientID: "0oalwkxvqtKeHBmLI4x6",
        redirectURI: "labs://scaffolding/implicit/callback")

    var loggedIn: Bool { token != nil }

    init(token: String? = nil,
         networkService: GraphQLController = GraphQLController()
    ) {
        self.token = token
        self.networkService = networkService
    }

    func provideToken(_ token: String) {
        self.token = token
    }

    private func query<T: Decodable>(
        expecting resultType: T.Type,
        query: String,
        options: [String: Any] = [:],
        completion: @escaping NetworkCompletion<T>
    ) {
        guard let token = token else {
            completion(.failure(AppQueryError.noToken))
            return
        }
        var variables: [String: Any] = ["token": token]
        options.forEach { key, value in variables[key] = value }
        networkService.queryRequest(T.self, query: query, completion: completion)
    }
}


extension AppQuerier: UserDataProvider {
    func logIn(_ completion: @escaping NetworkCompletion<User>) {
        query(expecting: User.self,
              query: GraphQLMutations.login,
              completion: completion)
    }
}


extension AppQuerier: PickupDataProvider {
    func fetchAllPickups(_ completion: @escaping NetworkCompletion<[Pickup]>) {
        completion(.failure(AppQueryError.unimplemented))
        // TODO
    }

    func schedulePickup(
        _ pickupInput: Pickup.ScheduleInput,
        completion: @escaping NetworkCompletion<Pickup.ScheduleResult>
    ) {
        completion(.failure(AppQueryError.unimplemented))
        // TODO
    }
}