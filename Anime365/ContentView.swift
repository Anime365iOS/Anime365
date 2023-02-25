//
//  ContentView.swift
//  Anime365
//
//  Created by Nikita Nafranets on 25.02.2023.
//

import SwiftUI

struct ContentView: View {
    @State var translations: [Translation] = []
    
    var body: some View {
        VStack {
            if translations.isEmpty {
                Text("Loading...")
            } else {
                List(translations) { translation in
                    Text(translation.title)
                }
            }
        }
        .onAppear {
            TranslationListController.shared.getTranslationList { result in
                switch result {
                case .success(let translations):
                    self.translations = translations
                case .failure(let error):
                    print("Error loading translations: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
