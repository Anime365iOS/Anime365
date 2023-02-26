//
//  ContentView.swift
//  Anime365
//
//  Created by Nikita Nafranets on 25.02.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var showWebView = false
    @State private var cookies: [HTTPCookie] = []
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: SerialView(id: 28471).navigationBarTitleDisplayMode(.inline)) {
                    Text("Перейти в аниме")
                }
                NavigationLink(destination: EmbedView(id: 4203402).navigationBarTitleDisplayMode(.inline)) {
                    Text("Перейти в embed")
                }
                if (cookies.isEmpty) {
                    Button("Login") {
                        showWebView = true
                    }
                    .sheet(isPresented: $showWebView, onDismiss: {
                        getWebViewCookies()
                    }) {
                        WebView()
                    }
                }

            }
            .navigationTitle("На главную")
        }
    }
    
    func getWebViewCookies() {
        self.cookies = HTTPCookieStorage.shared.cookies ?? [];
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
