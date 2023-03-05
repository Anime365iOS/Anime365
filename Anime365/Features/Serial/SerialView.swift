//
//  SerialView.swift
//  Anime365
//
//  Created by Nikita Nafranets on 25.02.2023.
//

import SwiftUI
import Combine
import AnimeAPI

struct SerialView: View {
    let id: Int
    @ObservedObject var viewModel = ViewModel()
    
    // 1
    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    // 2
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        
        // Image was pulled down
        if offset > 0 {
            return -offset
        }
        
        return 0
    }
    
    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height

        if offset > 0 {
            return imageHeight + offset
        }

        return imageHeight
    }
    
    private func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
        // 2
        let offset = geometry.frame(in: .global).maxY

        let height = geometry.size.height
        let blur = (height - max(offset, 0)) / height // 3 (values will range from 0 - 1)
        return blur * 6 // Values will range from 0 - 6
    }
    
    var body: some View {
        
        Group {
            if let serial = viewModel.serial {
                ScrollView {
                    GeometryReader { geometry in
                        Image(uiImage: serial.poster)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: self.getHeightForHeaderImage(geometry))
                            .blur(radius: self.getBlurRadiusForImage(geometry)) // 4
                            .clipped()
                            .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
                    }.frame(height: serial.poster.size.height / 1.2)
                    
                    VStack(alignment: .leading, spacing: 16) {

                        Text(serial.title.ru).font(.title)
                        if let description = serial.description {
                            Text(description).font(.body)
                            Text(description).font(.body)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16.0)
                }
                .edgesIgnoringSafeArea(.all)
            } else {
                ProgressView("Loading a serial with id: \(String(id))")
            }
            
        }
        .task {
            if (viewModel.serial == nil) {
                self.viewModel.fetchSerial(id: id)
            }
        }
        
    }
}

struct TranslationButton: View {
    let translation: EpisodeTranslation
    
    var body: some View {
        NavigationLink(destination: EmbedView(id: translation.id)) {
            Text(translation.authorsSummary)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.blue)
                .cornerRadius(5)
        }
    }
}

struct SerialView_Previews: PreviewProvider {
    static var previews: some View {
        SerialView(id: exampleSerial.id, viewModel: .mock(serial: exampleSerial));
    }
}


extension SerialView {
    class ViewModel: ObservableObject {
        private let api = AnimeAPI.shared
        
        @Published var serial: Serial?
        @Published var episode: EpisodeFull?
        
        init(serial: Serial? = nil) {
            self.serial = serial
        }
        
        static func mock(serial: Serial? = nil) -> ViewModel {
            return ViewModel(serial: serial)
        }
        
        func fetchSerial(id: Int) {
            //            Task.detached {
            //                do {
            //                    let data = try await self.api.getAnimeById(id: id)
            //                    DispatchQueue.main.async {
            //                        self.serial = data
            //                    }
            //                } catch {
            //                    print("Error fetching data: \(error.localizedDescription)")
            //                }
            //            }
        }
        
        func fetchEpisode(id: Int) {
            //            if episode != nil && episode?.id == id {
            //                return;
            //            }
            //
            //            Task.detached {
            //                do {
            //                    let data = try await self.api.getEpisodeInfo(id: id)
            //                    DispatchQueue.main.async {
            //                        self.episode = data
            //                    }
            //                } catch {
            //                    print("Error fetching data: \(error.localizedDescription)")
            //                }
            //            }
        }
    }
}


