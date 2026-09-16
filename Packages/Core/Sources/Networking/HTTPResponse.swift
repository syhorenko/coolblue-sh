//
//  HTTPResponse.swift
//  Core
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation

/// A successful HTTP reply, reduced to the two things callers above this layer need.
///
/// There is no `isSuccess` flag: `HTTPClient` rejects non-2xx replies as
/// `HTTPError.unacceptableStatusCode`, so a value of this type is already known-good and
/// mappers have no status check to forget.
public struct HTTPResponse: Equatable, Sendable {
    public let statusCode: Int
    public let body: Data

    public init(statusCode: Int, body: Data) {
        self.statusCode = statusCode
        self.body = body
    }
}
