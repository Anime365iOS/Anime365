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
import Photos
import CoreFoundation
import AnimeAPI

struct EmbedView: View {
    let id: Int
    @ObservedObject private var model = ViewModel()
    
    var body: some View {
        Group {
            VStack {
                if let player = model.player {
                    VideoPlayer(player: player).edgesIgnoringSafeArea(.all)
                } else {
                    ProgressView {
                        Text("\(String(format: "%.0f", model.progress * 100))% loading...")
                    }
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
        @Published var progress = 0.0
        
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
                if let bestStream = embed.stream.max(by: { $0.height > $1.height }) {
                    if let url = bestStream.urls.first {
                        return URL(string: url)
                    }
                }
            }
            return nil
        }
        
        var subtitleURL: URL?
        var videoURL: URL?
        var outputVideoURL: URL?
        
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
        
        func fetchVideo() async throws -> URL {
            let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("\(String(self.id)).mp4")

                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }

            return try await withCheckedThrowingContinuation { continuation in
                AF.download(streamURL!, to: destination).response { response in
                    if response.error != nil {
                        continuation.resume(with: .failure(response.error!))
                    } else {
                        continuation.resume(with: .success(response.fileURL!))
                    }
                }.downloadProgress { progress in
                    self.progress = progress.fractionCompleted
                }
            }
        }
        
        func writeSubtitles() {
            guard let videoURL = videoURL, let subtitleURL = subtitleURL else {
                return;
            }
            
            let asset = AVURLAsset(url: videoURL)
            let subtitleAsset = AVURLAsset(url: subtitleURL)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentsURL.appendingPathComponent("\(String(self.id))-output.mp4")
            outputVideoURL = outputURL
            
            try? FileManager.default.removeItem(at: outputURL)
            
            guard let assetReader = try? AVAssetReader(asset: asset) else {
                print("error creating asset reader. exiting: \(NSError())")
                return
            }
            
            guard let assetSubsReader = try? AVAssetReader(asset: subtitleAsset) else {
                print("error creating asset reader. exiting: \(NSError())")
                return
            }
            
            guard let assetWriter = try? AVAssetWriter(url: outputURL, fileType: .mp4) else {
                print("error creating asset writer. exiting: \(NSError())")
                return
            }
            
            // Copy metadata from the asset to the asset writer
            print("Copy metadata from the asset to the asset writer")
            var assetMetadata = [AVMetadataItem]()
            for metadataFormat in asset.availableMetadataFormats {
                assetMetadata.append(contentsOf: asset.metadata(forFormat: metadataFormat))
            }
            assetWriter.metadata = assetMetadata
            assetWriter.shouldOptimizeForNetworkUse = true
            
            print("Build up inputs and outputs for the reader and writer to carry over the tracks from the input movie into the new movie")
            // Build up inputs and outputs for the reader and writer to carry over the tracks from the input movie into the new movie
            var assetWriterInputsCorrespondingToOriginalTrackIDs = [NSNumber: AVAssetWriterInput]()
            var inputsOutputs = [[String: Any]]()
            
            for track in asset.tracks {
                let mediaType = track.mediaType
                
                // Make the reader
                let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: nil)
                assetReader.add(trackOutput)
                
                // Make the writer input, using a source format hint if a format description is available
                let input: AVAssetWriterInput
                let formatDescription = track.formatDescriptions.first as! CMFormatDescription?
                if formatDescription != nil {
                    input = AVAssetWriterInput(mediaType: mediaType, outputSettings: nil, sourceFormatHint: formatDescription)
                } else {
                    continue
                }
                
                // Carry over language code
                input.languageCode = track.languageCode
                input.extendedLanguageTag = track.extendedLanguageTag
                
                // Copy metadata from the asset track to the asset writer input
                var trackMetadata = [AVMetadataItem]()
                for metadataFormat in track.availableMetadataFormats {
                    trackMetadata.append(contentsOf: track.metadata(forFormat: metadataFormat))
                }
                input.metadata = trackMetadata
                
                // Add the input, if that's okay to do
                if assetWriter.canAdd(input) {
                    assetWriter.add(input)
                    
                    // Store the input and output to be used later when actually writing out the new movie
                    inputsOutputs.append(["input": input, "output": trackOutput])
                    
                    // Track inputs corresponsing to track IDs for later preservation of track groups
                    assetWriterInputsCorrespondingToOriginalTrackIDs[NSNumber(value: track.trackID)] = input
                } else {
                    print("skipping input because it cannot be added to the asset writer")
                }
            }
            
            let subtitleTrack = subtitleAsset.tracks(withMediaType: .text).first!
            let trackSubtitleOutput = AVAssetReaderTrackOutput(track: subtitleTrack, outputSettings: nil)
            assetSubsReader.add(trackSubtitleOutput)
            let formatSubtitleDescription = subtitleTrack.formatDescriptions.first as! CMFormatDescription?
            // Make the writer input, using a source format hint if a format description is available
            var subtitleInput = AVAssetWriterInput(mediaType: subtitleTrack.mediaType, outputSettings: nil, sourceFormatHint: formatSubtitleDescription)

            // Carry over language code
            subtitleInput.languageCode = "rus"
            subtitleInput.extendedLanguageTag = "ru-RU"
            
            // Copy metadata from the asset track to the asset writer input
            print("// Copy metadata from the asset track to the asset writer input")
            var trackMetadata = [AVMetadataItem]()
            for metadataFormat in subtitleTrack.availableMetadataFormats {
                trackMetadata.append(contentsOf: subtitleTrack.metadata(forFormat: metadataFormat))
            }
            subtitleInput.metadata = trackMetadata
            
            if assetWriter.canAdd(subtitleInput) {
                assetWriter.add(subtitleInput)
            } else {
                print("skipping subtitles input because it cannot be added to the asset writer")
            }
            
            print("Preserve track groups from the original asset")
            // Preserve track groups from the original asset
            var groupedSubtitles = false
            for trackGroup in asset.trackGroups {
                // Collect the inputs that correspond to the group's track IDs in an array
                var inputs = [AVAssetWriterInput]()
                var defaultInput: AVAssetWriterInput?
                for trackID in trackGroup.trackIDs {
                    if let input = assetWriterInputsCorrespondingToOriginalTrackIDs[trackID] {
                        inputs.append(input)
                        
                        // Determine which of the inputs is the default according to the enabled state of the corresponding tracks
                        if defaultInput == nil && asset.track(withTrackID: CMPersistentTrackID(trackID.intValue))?.isEnabled ?? false {
                            defaultInput = input
                        }
                    }
                }
                
                print("See if this is a legible (all of the tracks have characteristic AVMediaCharacteristicLegible), and group the new subtitle tracks with it if so")
                // See if this is a legible (all of the tracks have characteristic AVMediaCharacteristicLegible), and group the new subtitle tracks with it if so
                var isLegibleGroup = false
                for trackID in trackGroup.trackIDs {
                    if let track = asset.track(withTrackID: CMPersistentTrackID(trackID.intValue)), track.hasMediaCharacteristic(AVMediaCharacteristic.legible) {
                        isLegibleGroup = true
                    } else if isLegibleGroup {
                        isLegibleGroup = false
                        break
                    }
                }
                
                print("If it is a legible group, add the new subtitles to this group")
                // If it is a legible group, add the new subtitles to this group
                if !groupedSubtitles && isLegibleGroup {
                    inputs.append(contentsOf: [subtitleInput])
                    groupedSubtitles = true
                }
                
                let inputGroup = AVAssetWriterInputGroup(inputs: inputs, defaultInput: defaultInput)
                if assetWriter.canAdd(inputGroup) {
                    assetWriter.add(inputGroup)
                } else {
                    print("cannot add asset writer group")
                }
            }

            print("If no legible group was found to add the new subtitles to, create a group for them (if there are any)")
            // If no legible group was found to add the new subtitles to, create a group for them (if there are any)
            if !groupedSubtitles {
                let inputGroup = AVAssetWriterInputGroup(inputs: [subtitleInput], defaultInput: nil)
                if assetWriter.canAdd(inputGroup) {
                    assetWriter.add(inputGroup)
                } else {
                    print("cannot add asset writer group")
                }
            }
            
            // Preserve track references from original asset
            var trackReferencesCorrespondingToOriginalTrackIDs = [Int32: [String: [Int32]]]()
            for track in asset.tracks {
                var trackReferencesForTrack = [String: [Int32]]()
                let availableTrackAssociationTypes = Set(track.availableTrackAssociationTypes)
                for trackAssociationType in availableTrackAssociationTypes {
                    let associatedTracks = track.associatedTracks(ofType: trackAssociationType)
                    if associatedTracks.count > 0 {
                        var associatedTrackIDs = [Int32]()
                        for associatedTrack in associatedTracks {
                            associatedTrackIDs.append(associatedTrack.trackID)
                        }
                        trackReferencesForTrack[trackAssociationType.rawValue] = associatedTrackIDs
                    }
                }
                
                trackReferencesCorrespondingToOriginalTrackIDs[track.trackID] = trackReferencesForTrack
            }
            
            for referencingTrackIDKey in trackReferencesCorrespondingToOriginalTrackIDs.keys {
                guard let referencingInput = assetWriterInputsCorrespondingToOriginalTrackIDs[referencingTrackIDKey as NSNumber],
                      let trackReferences = trackReferencesCorrespondingToOriginalTrackIDs[referencingTrackIDKey]
                else { continue }
                
                for (trackReferenceTypeKey, referencedTrackIDs) in trackReferences {
                    for thisReferencedTrackID in referencedTrackIDs {
                        guard let referencedInput = assetWriterInputsCorrespondingToOriginalTrackIDs[thisReferencedTrackID as NSNumber],
                              referencingInput.canAddTrackAssociation(withTrackOf: referencedInput, type: trackReferenceTypeKey)
                        else { continue }
                        
                        referencingInput.addTrackAssociation(withTrackOf: referencedInput, type: trackReferenceTypeKey)
                    }
                }
            }

            print("Write the movie")
            // Write the movie
            if assetWriter.startWriting() {
                assetWriter.startSession(atSourceTime: CMTime.zero)
                
                let dispatchGroup = DispatchGroup()
                assetReader.startReading()
                
                // Write samples from AVAssetReaderTrackOutputs
                for inputOutput in inputsOutputs {
                    dispatchGroup.enter()
                    let requestMediaDataQueue = DispatchQueue(label: "request media data", qos: .userInitiated)
                    guard let input = inputOutput["input"] as? AVAssetWriterInput,
                          let assetReaderTrackOutput = inputOutput["output"] as? AVAssetReaderTrackOutput else {
                        continue
                    }
                    input.requestMediaDataWhenReady(on: requestMediaDataQueue) {
                        while input.isReadyForMoreMediaData {
                            guard let nextSampleBuffer = assetReaderTrackOutput.copyNextSampleBuffer() else {
                                input.markAsFinished()
                                dispatchGroup.leave()
                                if assetReader.status == .failed {
                                    print("the reader failed: \(String(describing: assetReader.error))")
                                }
                                break
                            }
                            input.append(nextSampleBuffer)
                        }
                    }
                }
                
                let subtitlesInputOutputs = [["input": subtitleInput, "output": trackSubtitleOutput]]
                var counter = 0;
                // Write samples from SubtitlesTextReaders
                print("Write samples from SubtitlesTextReaders")
                
                assetSubsReader.startReading()
                for subtitlesInputOutput in subtitlesInputOutputs {
                    counter += 1
                    print(counter)
                    dispatchGroup.enter()
                    print("enter group")
                    let requestMediaDataQueue = DispatchQueue(label: "request media data", qos: .userInitiated)
                    let input = subtitlesInputOutput["input"] as? AVAssetWriterInput
                    let subtitlesTextReader = subtitlesInputOutput["output"] as? AVAssetReaderTrackOutput

                    print("before requestMediaDataWhenReady")
                    input!.requestMediaDataWhenReady(on: requestMediaDataQueue) {
                        print("requestMediaDataWhenReady")
                        while input!.isReadyForMoreMediaData {
                            guard let nextSampleBuffer = subtitlesTextReader!.copyNextSampleBuffer() else {
                                input!.markAsFinished()
                                dispatchGroup.leave()
                                break
                            }
                            input!.append(nextSampleBuffer)
                        }
                    }
                }
                
                dispatchGroup.wait()
                print("leave group")
                assetReader.cancelReading()
                
                dispatchGroup.enter()
                assetWriter.finishWriting {
                    if assetWriter.status == .completed {
                        print("writing success to \(assetWriter.outputURL)")
                    } else if assetWriter.status == .failed {
                        print("writer failed with error: \(String(describing: assetWriter.error))")
                    }
                    dispatchGroup.leave()
                }
                dispatchGroup.wait()
            } else {
                print("asset writer failed to start writing: \(String(describing: assetWriter.error))")
            }
        }
        
        func createPlayer() async throws {
//            guard let videoURL = videoURL, let subtitleURL = subtitleURL else {
//                return;
//            }
            
//            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let fileURL = documentsURL.appendingPathComponent("\(String(self.id))-video.mp4")
//
//            try? FileManager.default.removeItem(at: fileURL)

//            let videoAsset = AVURLAsset(url: videoURL)
//            let subtitleAsset = AVURLAsset(url: subtitleURL)
//
//            // Create a new composition
//            let composition = AVMutableComposition()
//
//
//            let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
//            let videoAssetTrack = try! await videoAsset.loadTracks(withMediaType: .video).first!
//            let videoTimeRange = try! await videoAssetTrack.load(.timeRange)
//            try! videoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoTimeRange.duration), of: videoAssetTrack, at: .zero)
//
//            let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
//            let audioAssetTrack = try! await videoAsset.loadTracks(withMediaType: .audio).first!
//            let audioTimeRange = try! await audioAssetTrack.load(.timeRange)
//            try! audioTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: audioTimeRange.duration), of: audioAssetTrack, at: .zero)
//
//            // Create a mutable composition and subtitle track
//            let subtitleTrack = composition.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid)!
//
//            let subtitleAssetTrack = try await subtitleAsset.loadTracks(withMediaType: .text).first!
//            let subtitleTimeRange = try! await subtitleAssetTrack.load(.timeRange)
//            // Insert the subtitle asset into the composition
//            try! subtitleTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: subtitleTimeRange.duration), of: subtitleAssetTrack, at: .zero)
//
            print("START WRITE SUBS")
            writeSubtitles();
            let video = AVAsset(url: outputVideoURL!);
            print("play \(String(describing: outputVideoURL))")
            let playerItem = AVPlayerItem(asset: video)
            let isAirEnabled = video.isCompatibleWithAirPlayVideo;
            print(isAirEnabled)
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
                self.player?.allowsExternalPlayback = isAirEnabled
                self.player?.usesExternalPlaybackWhileExternalScreenIsActive = true
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
                                self.videoURL = try await self.fetchVideo()
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
