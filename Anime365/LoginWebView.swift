//
//  LoginWebView.swift
//  Anime365
//
//  Created by Nikita Nafranets on 25.02.2023.
//
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url = URL(string: "https://smotret-anime.com/users/login")!
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView didFinish")
        }
        
        func webViewDidClose(_ webView: WKWebView) {
            print("WebView didClose")
        }
    }
}

//struct LoginWebView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginWebView()
//    }
//}
