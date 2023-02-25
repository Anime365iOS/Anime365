//
//  ContentView.swift
//  Anime365
//
//  Created by Nikita Nafranets on 25.02.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var cookies: [HTTPCookie] = []
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: SerialView(id: 28471).navigationBarTitleDisplayMode(.inline)) {
                    Text("Перейти в аниме")
                }
                NavigationLink(destination: {
                    WebView(url: URL(string: "https://smotret-anime.com/")!, cookiesCompletion: { cookies in
                        print(cookies)
                        self.cookies = cookies
                    }).navigationBarTitleDisplayMode(.inline)
                }) {
                    Text("Получить куку")
                }
                Text("Cookies: \(cookies.count)")
            }.navigationTitle("На главную")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
