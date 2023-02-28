//
//  EmbedView.swift
//  Anime365
//
//  Created by Nikita Nafranets on 26.02.2023.
//

import SwiftUI
import AVKit
import AVFoundation
import Alamofire

struct EmbedView: View {
    let id: Int
    @ObservedObject private var model = ViewModel()
    
    var body: some View {
        Group {
            VStack {
                if let player = model.player {
                    PlayerView(player: player).edgesIgnoringSafeArea(.all)
                }
            }
        }.onAppear {
            model.fetch(id: id)
        }.onDisappear {
            model.stopPlayer()
        }
    }
}


struct EmbedView_Previews: PreviewProvider {
    static var previews: some View {
        EmbedView(id: 4203402)
    }
}


struct PlayerView: UIViewControllerRepresentable {
    
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true
        return playerViewController
    }
    
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        // do nothing
    }
}



extension EmbedView {
    class ViewModel: ObservableObject {
        private let api = AnimeAPI.shared
        @Published var embed: Embed?
        @Published var player: AVPlayer?

        
        var id: Int {
            if let embed = embed {
                if let range = embed.subtitlesVttURL.range(of: #"[0-9]+"#, options: .regularExpression) {
                    let numberString = embed.subtitlesVttURL[range]
                    if let number = Int(numberString) {
                        return number
                    }
                }
            }
            return 0
        }
        
        var streamURL: URL? {
            if let embed = embed {
                if let bestStream = embed.stream.max(by: { $0.height < $1.height }) {
                    if let url = bestStream.urls.first {
                        return URL(string: url)
                    }
                }
            }
            return nil
        }
        
        var subtitleURL: URL?
        
        func fetchSubtitles() async throws -> URL {
            let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("\(String(self.id)).vtt")

                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }

            return try await withCheckedThrowingContinuation { continuation in
                AF.download(embed!.subtitlesVttURL, to: destination).response { response in
                    if response.error != nil {
                        continuation.resume(with: .failure(response.error!))
                    } else {
                        continuation.resume(with: .success(response.fileURL!))
                    }
                }
            }
        }
        
        func createPlayer() async throws {
            if let streamURL = streamURL, let subtitleURL = subtitleURL {
                print(streamURL, subtitleURL)
                let videoAsset = AVURLAsset(url: streamURL)
                let subtitleAsset = AVURLAsset(url: subtitleURL)
                
                let composition = AVMutableComposition()
                let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
                let videoAssetTrack = try! await videoAsset.loadTracks(withMediaType: .video).first!
                let videoTimeRange = try! await videoAssetTrack.load(.timeRange)
                try! videoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoTimeRange.duration), of: videoAssetTrack, at: .zero)
                
                let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
                let audioAssetTrack = try! await videoAsset.loadTracks(withMediaType: .audio).first!
                let audioTimeRange = try! await audioAssetTrack.load(.timeRange)
                try! audioTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: audioTimeRange.duration), of: audioAssetTrack, at: .zero)

                // Create a mutable composition and subtitle track
                let subtitleTrack = composition.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid)!

                let subtitleAssetTrack = try await subtitleAsset.loadTracks(withMediaType: .text).first!
                let subtitleTimeRange = try! await subtitleAssetTrack.load(.timeRange)
                // Insert the subtitle asset into the composition
                try! subtitleTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: subtitleTimeRange.duration), of: subtitleAssetTrack, at: .zero)
            
                
                
                let playerItem = AVPlayerItem(asset: composition)
                
                let titleItem = AVMutableMetadataItem()
                titleItem.identifier = .commonIdentifierTitle
                titleItem.value = NSString(string: "Episode 8")

                let subtitleItem = AVMutableMetadataItem()
                subtitleItem.identifier = .iTunesMetadataTrackSubTitle
                subtitleItem.value = NSString(string: "Isekai Nonbiri Nouka")
                
                playerItem.externalMetadata = [
                    titleItem,
                    subtitleItem
                ]
                
                DispatchQueue.main.async {
                    self.player = AVPlayer(playerItem: playerItem)
                }
            }
        }
        
        func stopPlayer() {
            player?.allowsExternalPlayback = false
            player?.pause()
            player = nil
        }
        
        func fetch(id: Int) {
            Task.detached {
                do {
                    let data = try await self.api.getTranslationEmbedInfo(id: id)
                    DispatchQueue.main.async {
                        self.embed = data
                        Task.detached {
                            do {
                                self.subtitleURL = try await self.fetchSubtitles()
                                try await self.createPlayer()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                } catch {
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
}
