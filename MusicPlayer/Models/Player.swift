//
//  Player.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 09.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import MediaPlayer
import AVFoundation

protocol PlayerDelegate: class {
    
    func playerStopped()
    
    func playerFailedSong(_ song: Song)
    
    func playerPausedSong(_ song: Song)
    
    func playerResumedSong(_ song: Song)
    
    func playerUpdatedSongCurrentTime(currentTime: Float)
}

final class Player: NSObject {
    
    static let main = Player()
    
    weak var delegate: PlayerDelegate?
    
    private let audioSession = AVAudioSession.sharedInstance()
    
    private var audioPlayer: AVAudioPlayer?
    
    var currentSong: Song? {
        guard let index = currentSongIndex, index < songsList.count else {
            return nil
        }
        return songsList[index]
    }
    
    private var currentSongIndex: Int?
    
    private var timer: Timer!
    
    private var songsList = [Song]()
    
    private(set) var originalSongsList = [Song]() {
        didSet {
            if shuffleState {
                songsList = originalSongsList
                shuffleSongsList()
            } else {
                songsList = originalSongsList
            }
        }
    }
    
    var repeatState = false
    
    var shuffleState = false {
        didSet {
            if shuffleState {
                shuffleSongsList()
            } else {
                if let currentSong = currentSong {
                    songsList = originalSongsList
                    if let index = songsList.index(of: currentSong) {
                        currentSongIndex = index
                    }
                } else {
                    songsList = originalSongsList
                    currentSongIndex = 0
                }
            }
        }
    }
    
    var currentTime: Float {
        get {
            return Float(audioPlayer?.currentTime ?? 0)
        }
        set {
            setupCurrentTime(TimeInterval(newValue))
        }
    }
    
    var currentDuration: Float {
        return Float(audioPlayer?.duration ?? 0)
    }
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    private override init() {
        super.init()
        setupRemoteCenterCommands()
        setupInterruptionObserver()
        try? audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: .default)
    }
    
    func playSong(with index: Int, in songsList: [Song]) {
        currentSongIndex = index
        originalSongsList = songsList
        if let currentSong = currentSong {
            playSong(currentSong)
        }
    }
    
    func play(song: Song) {
        playSong(with: 0, in: [song])
    }
    
    private func playSong(_ song: Song) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: song.url)
            audioPlayer?.delegate = self
        } catch {
            stop()
            delegate?.playerFailedSong(song)
            return
        }
        
        play()
        startTimer()
    }
    
    func playSongsList(_ songs: [Song]) {
        if !songs.isEmpty {
            repeatState = false
            shuffleState = false
            originalSongsList = songs
            currentSongIndex = 0
            if let currentSong = currentSong {
                playSong(currentSong)
            }
        }
    }
    
    func shuffleAndPlaySongsList(_ songs: [Song]) {
        if !songs.isEmpty {
            currentSongIndex = nil
            originalSongsList = songs
            shuffleState = true
            currentSongIndex = 0
            if let currentSong = currentSong {
                playSong(currentSong)
            }
        }
    }
    
    private func shuffleSongsList() {
        if let songIndex = currentSongIndex,
            let currentSong = currentSong {
            songsList.remove(at: songIndex)
            songsList.shuffle()
            songsList.insert(currentSong, at: 0)
        } else {
            songsList.shuffle()
        }
        currentSongIndex = 0
    }
    
    private func startTimer() {
        stopTimer()
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(currentTimeChanged), userInfo: nil, repeats: true)
            timer.fire()
        }
    }
    
    private func stopTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    @objc private func currentTimeChanged() {
        if isPlaying {
            delegate?.playerUpdatedSongCurrentTime(currentTime: currentTime)
        }
    }
    
    func play() {
        if let player = audioPlayer, let song = currentSong {
            DispatchQueue.global(qos: .userInteractive).async {
                player.play()
                DispatchQueue.main.async {
                    self.delegate?.playerResumedSong(song)
                    self.setupRemoteCenterInfo()
                }
            }
        }
    }
    
    func pause() {
        if let player = audioPlayer, let song = currentSong {
            DispatchQueue.global(qos: .userInteractive).async {
                player.pause()
                DispatchQueue.main.async {
                    self.delegate?.playerPausedSong(song)
                    self.setupRemoteCenterInfo()
                }
            }
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentSongIndex = nil
        delegate?.playerStopped()
        clearRemoteCenterInfo()
        stopTimer()
    }
    
    func playNextSong() {
        guard currentSongIndex != nil else { return }
        
        currentSongIndex! += 1
        if currentSongIndex! < songsList.count {
            if let currentSong = currentSong {
                playSong(currentSong)
            }
        } else {
            currentSongIndex = 0
            if let currentSong = currentSong {
                playSong(currentSong)
                pause()
            }
        }
    }
    
    func playPreviousSong() {
        guard currentSongIndex != nil else { return }
        
        currentSongIndex! -= 1
        if currentSongIndex! < 0 {
            currentSongIndex = 0
        }
        if let currentSong = currentSong {
            playSong(currentSong)
        }
    }
    
    private func setupCurrentTime(_ time: TimeInterval) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.audioPlayer?.currentTime = time
            DispatchQueue.main.async {
                self.setupRemoteCenterInfo()
            }
        }
    }
    
    private func setupRemoteCenterInfo() {
        guard let player = audioPlayer, let song = currentSong else {
            return clearRemoteCenterInfo()
        }
        
        let title = song.title
        var nowPlayingInfo = [MPMediaItemPropertyTitle : title] as [String : Any]
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1 : 0
        
        if let album = song.album?.title {
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        }
        if let artist = song.album?.artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
        if let artwork = song.artwork {
            let albumArtwork = MPMediaItemArtwork(boundsSize: artwork.size) { _ in
                return artwork
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = albumArtwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupRemoteCenterCommands() {
        let remoteCenter = MPRemoteCommandCenter.shared()
        remoteCenter.playCommand.addTarget { event in
            self.play()
            return .success
        }
        remoteCenter.pauseCommand.addTarget { event in
            self.pause()
            return .success
        }
        remoteCenter.nextTrackCommand.addTarget { event in
            self.playNextSong()
            return .success
        }
        remoteCenter.previousTrackCommand.addTarget { event in
            self.playPreviousSong()
            return .success
        }
        remoteCenter.changePlaybackPositionCommand.addTarget { event in
            let currentTime = (event as! MPChangePlaybackPositionCommandEvent).positionTime
            self.setupCurrentTime(currentTime)
            return .success
        }
        remoteCenter.togglePlayPauseCommand.addTarget { event in
            self.isPlaying ? self.pause() : self.play()
            return .success
        }
    }
    
    private func clearRemoteCenterInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterrupted), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc private func audioSessionInterrupted() {
        pause()
    }
    
    func removeSongFromSongsList(song: Song) {
        if !songsList.contains(song) { return }
        
        if currentSong == song {
            stop()
        }
        
        for (index, eachSong) in songsList.enumerated() {
            if eachSong == song {
                songsList.remove(at: index)
                if currentSongIndex != nil, currentSongIndex! > index {
                    currentSongIndex! -= 1
                }
            }
        }
        
        for (index, eachSong) in originalSongsList.enumerated() {
            if eachSong == song {
                originalSongsList.remove(at: index)
            }
        }
    }
    
    func removeSongFromSongsList(with index: Int) {
        if currentSongIndex == index {
            stop()
        }
        
        var songsArray = originalSongsList
        songsArray.remove(at: index)
        originalSongsList = songsArray
        
        if !shuffleState, currentSongIndex != nil, currentSongIndex! > index {
            currentSongIndex! -= 1
        }
    }
    
    func updateSongsList(with songs: [Song]) {
        if let currentSong = currentSong, songs.contains(currentSong) {
            originalSongsList = songs
            if let index = songsList.index(of: currentSong) {
                currentSongIndex = index
            }
        } else {
            currentSongIndex = 0
            originalSongsList = songs
        }
    }
    
    func clearSongsList() {
        if let currentSong = currentSong {
            currentSongIndex = 0
            originalSongsList = [currentSong]
        } else {
            originalSongsList.removeAll()
        }
    }
    
    deinit {
        stopTimer()
        NotificationCenter.default.removeObserver(self)
    }
}

extension Player: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch (repeatState, shuffleState) {
        case (false, false), (false, true) :
            playNextSong()
            
        case (true, true), (true, false) :
            if let song = currentSong {
                playSong(song)
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stop()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
