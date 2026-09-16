//
//  AppEnvironment.swift
//  CoolblueSHorenko
//
//  Created by Serhii Horenko on 16/09/2026.
//

import DesignSystem
import Foundation
import Networking

/// The composition root.
///
/// This is the only place in the whole codebase that names a concrete implementation:
/// `URLSessionHTTPClient` is chosen here and handed to features as an `HTTPClient`. That
/// is what lets `Packages/Product` be tested with stubs without ever knowing URLSession
/// exists — and why no view model builds its own dependencies.
struct AppEnvironment {
    let httpClient: HTTPClient
    let searchAPIBaseURL: URL

    /// The wiring the shipping app uses. A test or preview build assembles its own.
    static func live() -> AppEnvironment {
        ImageCacheConfiguration.apply()

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        // A search started in a lift should complete when signal returns rather than
        // failing immediately.
        configuration.waitsForConnectivity = true
        configuration.requestCachePolicy = .useProtocolCachePolicy

        return AppEnvironment(
            httpClient: URLSessionHTTPClient(session: URLSession(configuration: configuration)),
            searchAPIBaseURL: AppEndpoints.searchAPI
        )
    }
}
