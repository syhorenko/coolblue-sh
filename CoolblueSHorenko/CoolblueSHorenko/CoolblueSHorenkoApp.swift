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
    private let environment = AppEnvironment.live()

    var body: some Scene {
        WindowGroup {
            RootView(environment: environment)
        }
    }
}
