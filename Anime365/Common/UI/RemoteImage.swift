//
//  RemoteImage.swift
//  Anime365
//
//  Created by Nikita Nafranets on 25.02.2023.
//

import SwiftUI
import Combine

struct RemoteImage: View {
    let src: String
    
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ProgressView()
            }
        }.onAppear {
            imageLoader.loadImage(from: src)
        }
    }
}


struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(src: "https://smotret-anime.com/posters/28471.22312040664.jpg")
    }
}

extension RemoteImage {
    class ImageLoader: ObservableObject {
        @Published var image: UIImage?
        
        private var cancellable: AnyCancellable?
        
        func loadImage(from urlString: String) {
            guard let url = URL(string: urlString) else {
                return
            }
            
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] image in
                    self?.image = image
                }
        }
    }
}
