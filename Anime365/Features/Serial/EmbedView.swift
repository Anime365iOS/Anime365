//
//  EmbedView.swift
//  Anime365
//
//  Created by Nikita Nafranets on 26.02.2023.
//

import SwiftUI
import AVKit
import AVFoundation

struct EmbedView: View {
    let id: Int
    @ObservedObject private var model = ViewModel()
    
    var body: some View {
        Group {
            VStack {
                if let player = model.player {
                    VideoPlayer(player: player)
                }
            }
        }.task {
            self.model.fetch(id: id)
        }
    }
}

//struct HLSPlayer: UIViewControllerRepresentable {
//    let videoSrc: URL
//    let subtitleSrc: URL
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<HLSPlayer>) -> AVPlayerViewController {
//        let playerViewController = AVPlayerViewController()
//        let videoAsset = AVURLAsset(url: videoSrc)
//        let subtitleAsset = AVURLAsset(url: subtitleSrc)
//        let composition = AVMutableComposition()
//        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else { return playerViewController }
//        guard let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first else { return playerViewController }
//        try! videoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAssetTrack.timeRange.duration), of: videoAssetTrack, at: .zero)
//
//        // Create a mutable composition and subtitle track
//        guard let subtitleTrack = composition.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid) else { return playerViewController }
//
//        let tracks = try await subtitleAsset.loadTracks(withMediaType: .subtitle)
//        // Insert the subtitle asset into the composition
//        guard let subtitleAssetTrack = subtitleAsset.tracks(withMediaType: .text).first else { return playerViewController }
//        try! subtitleTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: subtitleAssetTrack.timeRange.duration), of: subtitleAssetTrack, at: .zero)
//
//        // Add the subtitle track to the video track
//        let instruction = AVMutableVideoCompositionInstruction()
//        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: videoAssetTrack.timeRange.duration)
//        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
//        let subtitleLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: subtitleTrack)
//        instruction.layerInstructions = [layerInstruction, subtitleLayerInstruction]
//        let videoComposition = AVMutableVideoComposition()
//        videoComposition.instructions = [instruction]
//        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
//        videoComposition.renderSize = CGSize(width: videoAssetTrack.naturalSize.width, height: videoAssetTrack.naturalSize.height)
//
//        let playerItem = AVPlayerItem(asset: composition)
//        let player = AVPlayer(playerItem: playerItem)
//
//        playerViewController.player = player
//        return playerViewController
//    }
//
//    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<HLSPlayer>) {
//    }
//}

struct EmbedView_Previews: PreviewProvider {
    static var previews: some View {
        EmbedView(id: 4203402)
    }
}


extension EmbedView {
    class ViewModel: ObservableObject {
        private let api = AnimeAPI.shared
        @Published var embed: Embed?
        @Published var player: AVPlayer?
        
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
        
        var subtitleURL: URL? {
            if let embed = embed {
                return URL(string: embed.subtitlesVttURL)
//                return URL(string: "https://smotret-anime.com\(embed.subtitlesURL)")
            }
            return nil
        }
        
        func createPlayer() async throws {
            if let streamURL = streamURL, let subtitleURL = subtitleURL {
                print(streamURL, subtitleURL)
                let videoAsset = AVURLAsset(url: streamURL)
                let subtitleAsset = AVURLAsset(url: subtitleURL)
                let tracks = try! await subtitleAsset.load(.tracks)
                for track in tracks {
                    print(track.mediaType, track.trackID, track.description)
                }
                print("done")
                let composition = AVMutableComposition()
                let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
                let videoAssetTrack = try! await videoAsset.loadTracks(withMediaType: .video).first!
                let videoTimeRange = try! await videoAssetTrack.load(.timeRange)
                try! videoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoTimeRange.duration), of: videoAssetTrack, at: .zero)
                
                // Create a mutable composition and subtitle track
                let subtitleTrack = composition.addMutableTrack(withMediaType: .subtitle, preferredTrackID: kCMPersistentTrackID_Invalid)!

                let subtitleAssetTrack = try await subtitleAsset.loadTracks(withMediaType: .subtitle).first!
                print(subtitleAssetTrack.description)
                let subtitleTimeRange = try! await subtitleAssetTrack.load(.timeRange)
                // Insert the subtitle asset into the composition
                try! subtitleTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: subtitleTimeRange.duration), of: subtitleAssetTrack, at: .zero)

                // Add the subtitle track to the video track
                let instruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = CMTimeRangeMake(start: .zero, duration: videoAssetTrack.timeRange.duration)
                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
                let subtitleLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: subtitleTrack)
                instruction.layerInstructions = [layerInstruction, subtitleLayerInstruction]
                let videoComposition = AVMutableVideoComposition()
                videoComposition.instructions = [instruction]
                videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
                let videoNaturalSize = try await videoAssetTrack.load(.naturalSize)
                videoComposition.renderSize = videoNaturalSize
                
                let playerItem = AVPlayerItem(asset: composition)
                player = AVPlayer(playerItem: playerItem)
            }
        }
        
        func fetch(id: Int) {
            Task.detached {
                do {
                    let data = try await self.api.getTranslationEmbedInfo(id: id)
                    DispatchQueue.main.async {
                        self.embed = data
                        Task.detached {
                            do {
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
