//
//  UserFacingError.swift
//  EcoSoapBank
//
//  Created by Jon Bash on 2020-08-20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import Foundation


enum ESBError {
    static let unknown = CustomError(
        errorDescription: "An unknown error occurred",
        recoverySuggestion: "Please try again a little later, and contact us if it occurs repeatedly.")
}


struct CustomError: LocalizedError {
    let errorDescription: String
    let recoverySuggestion: String
}


struct ErrorMessage: CustomStringConvertible {
    let title: String
    let message: String
    let error: Error?

    private static let fallbackTitle = "An unknown error occurred."
    private static let fallbackMessage = "Please contact the developer for more information."

    init(title: String, message: String, error: Error? = nil) {
        self.title = title
        self.message = message
        if let error = error {
            self.error = error
        } else {
            self.error = CustomError(errorDescription: title,
                                     recoverySuggestion: message)
        }
    }

    init(_ error: Error? = nil) {
        if let error = error as? LocalizedError {
            self.init(
                title: error.errorDescription ?? Self.fallbackTitle,
                message: error.recoverySuggestion
                    ?? error.failureReason
                    ?? Self.fallbackMessage
            )
        } else {
            self.init(title: Self.fallbackTitle,
                      message: Self.fallbackMessage,
                      error: error)
        }
    }

    var description: String {
        var desc = ""
        if let error = error {
            desc += "\(error)\n"
        }
        desc += "\(title)\n\(message)"
        return desc
    }
}


enum MockError: LocalizedError {
    case shouldFail

    var errorDescription: String? {
        "Uh oh! You found a bug."
    }

    var recoverySuggestion: String? {
        "You shouldn't be seeing this! Please contact us and let us know how you got here so we can fix it. Thank you!"
    }
}


extension Result where Failure == Error {
    static func mockFailure() -> Result<Success, Failure> {
        Result.failure(MockError.shouldFail)
    }
}
