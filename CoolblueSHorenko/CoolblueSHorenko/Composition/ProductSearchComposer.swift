//
//  ProductSearchComposer.swift
//  CoolblueSHorenko
//
//  Created by Serhii Horenko on 16/09/2026.
//

import ProductData
import ProductPresentation
import ProductUI
import SwiftUI

enum ProductSearchComposer {

    static func makeSearchScreen(environment: AppEnvironment) -> some View {
        let loader = RemoteProductSearchLoader(
            baseURL: environment.searchAPIBaseURL,
            client: environment.httpClient
        )

        return ProductSearchView(viewModel: ProductSearchViewModel(loader: loader))
    }
}
