//
//  SerialView.swift
//  Anime365
//
//  Created by Nikita Nafranets on 25.02.2023.
//

import SwiftUI
import Combine

struct SerialView: View {
    let id: Int
    @ObservedObject private var viewModel = ViewModel()
    @State var episodeIsSelected: Bool = false
    @State var selectedTab: String = "RuSubs"
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let serial = viewModel.serial {
                    // Show the title of the serial
                    Text(serial.title)
                        .font(.title)
                    
                    
                    HStack(alignment: .center, spacing: 5.0) {
                        Spacer()
                        // Show the poster of the show
                        RemoteImage(src: serial.posterURL)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 300)
                            .cornerRadius(8)
                        
                        Spacer()
                    }

                    // Show the year and season and the rating of the show
                    HStack(spacing: 10) {
                        Spacer()
                        Text(String(serial.year))
                        Text(serial.season)
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(serial.myAnimeListScore)
                        }
                        Spacer()
                    }
                    // Show the list of genres
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Genres:")
                            .font(.headline)
                        HStack {
                            ForEach(serial.genres, id: \.id) { genre in
                                Text(genre.title)
                            }
                        }
                    }
                    
                    // Show the description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description:")
                            .font(.headline)
                        Text(serial.descriptions.first?.value ?? "")
                    }
                    
                    // Show the list of episodes
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Episodes:")
                            .font(.headline)
                        VStack {
                            ForEach(serial.episodes, id: \.id) { episode in
                                Button(action: {
                                    episodeIsSelected = true
                                    viewModel.fetchEpisode(id: episode.id)
                                }, label: {
                                    Text(episode.episodeFull)
                                })
                            }
                        }
                    }
                } else {
                    ProgressView("Loading a serial with id: \(String(id))")
                }
            }
            .padding()
//            .sheet(isPresented: $episodeIsSelected) {
//                if let episode = viewModel.episode {
//                    let episodesByType = Dictionary(grouping: episode.translations) { $0.type.rawValue }
//                        .mapValues { $0.sorted { $0.authorsSummary < $1.authorsSummary } }
//
//                    VStack {
//                        Picker(selection: $selectedTab, label: Text("")) {
//                            Text("RuSubs").tag("RuSubs")
//                            Text("EnSubs").tag("EnSubs")
//                            Text("RuDub").tag("RuDub")
//                            Text("Raw").tag("Raw")
//                        }
//                        .pickerStyle(SegmentedPickerStyle())
//
//                        // Use a nested ForEach loop to display the buttons
//                        ForEach(episode.translation.types.filter { $0.key == selectedTab }, id: \.key) { type in
//                            ForEach(type.value, id: \.id) { subType in
//                                Button(subType.authorsSummary) {
//                                    // Handle button tap
//                                }
//                            }
//                        }
//
//                        Spacer()
//                    }
//                    .padding()
//                } else {
//                    ProgressView("Loading a episode with id: \(String(id))")
//                }
//            }
            
        }
        .task {
            self.viewModel.fetchSerial(id: id)
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
        SerialView(id: 28471)
    }
}


extension SerialView {
    class ViewModel: ObservableObject {
        private let api = AnimeAPI.shared
        
        @Published var serial: Serial?
        @Published var episode: EpisodeFull?
        
        func fetchSerial(id: Int) {
            Task.detached {
                do {
                    let data = try await self.api.getAnimeById(id: id)
                    DispatchQueue.main.async {
                        self.serial = data
                    }
                } catch {
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
        
        func fetchEpisode(id: Int) {
            if episode != nil && episode?.id == id {
                return;
            }
            
            Task.detached {
                do {
                    let data = try await self.api.getEpisodeInfo(id: id)
                    DispatchQueue.main.async {
                        self.episode = data
                    }
                } catch {
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
}


