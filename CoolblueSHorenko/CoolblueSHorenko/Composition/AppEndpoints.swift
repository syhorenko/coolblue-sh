//
//  AppEndpoints.swift
//  CoolblueSHorenko
//
//  Created by Serhii Horenko on 16/09/2026.
//

import Foundation

/// Every host the app talks to.
///
/// Lives in the app target because it is environment configuration, not feature logic: a
/// staging or mock build changes this file and nothing in `Packages/`.
enum AppEndpoints {
    /// Coolblue mobile assignment API. Paths (`search`) are appended by the feature.
    ///
    /// The one force unwrap in the codebase, on a string literal that cannot change at
    /// runtime. The alternative — an optional `URL` every caller must unwrap — would push
    /// an impossible failure path into the feature code. The lint suppression is
    /// deliberate and scoped to this line so it stays visible in review.
    static let searchAPI = URL(string: "https://bdk0sta2n0.execute-api.eu-west-1.amazonaws.com/mobile-assignment")! // swiftlint:disable:this force_unwrapping
}
