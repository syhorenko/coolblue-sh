//
//  CoolblueSHorenkoApp.swift
//  CoolblueSHorenko
//
//  Created by Serhii Horenko on 15/09/2026.
//

import SwiftUI

@main
struct CoolblueSHorenkoApp: App {
    /// Built once, at launch. Everything the app needs is assembled here and passed
    /// down; nothing reaches for a singleton.
    private let environment: AppEnvironment = {
        #if DEBUG
        if let stubbed = UITestSupport.environment() {
            return stubbed
        }
        #endif

        return .live()
    }()

    var body: some Scene {
        WindowGroup {
            ProductSearchComposer.makeSearchScreen(environment: environment)
        }
    }
}
