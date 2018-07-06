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
    
    private(set) var currentSong: Song?
    
    private var currentSongIndex = 0
    
    private var shuffleArray = [Song]()
    
    private var timer: Timer!
    
    var songsList = [Song]() {
        didSet {
            if songsList != oldValue {
                if shuffleState {
                    setupShuffleArray()
                }
            }
        }
    }
    
    var repeatState = false
    
    var shuffleState = false {
        didSet {
            if shuffleState {
                setupShuffleArray()
            } else {
                shuffleArray.removeAll()
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
        try? audioSession.setCategory(AVAudioSessionCategoryPlayback)
    }
    
    func playSong(_ song: Song, with index: Int, in songsList: [Song]) {
        playSong(song)
        currentSongIndex = index
        self.songsList = songsList
    }
    
    func playSong(_ song: Song) {
        currentSong = song
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: currentSong!.url)
            audioPlayer?.delegate = self
        } catch {
            stop()
            delegate?.playerFailedSong(currentSong!)
            return
        }
        
        play()
        startTimer()
    }
    
    func playSongsList(_ songs: [Song]) {
        if !songs.isEmpty {
            repeatState = false
            shuffleState = false
            songsList = songs
            currentSongIndex = 0
            playSong(songsList.first!)
        }
    }
    
    func shuffleAndPlaySongsList(_ songs: [Song]) {
        if !songs.isEmpty {
            currentSong = nil
            songsList = songs
            shuffleState = true
            currentSongIndex = 0
            playSong(shuffleArray.first!)
        }
    }
    
    private func setupShuffleArray() {
        shuffleArray = songsList.shuffled()
        guard let currentSong = currentSong else { return }
        if let index = shuffleArray.index(of: currentSong) {
            shuffleArray.remove(at: index)
            shuffleArray.insert(currentSong, at: 0)
        }
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
            player.play()
            delegate?.playerResumedSong(song)
            setupRemoteCenterInfo()
        }
    }
    
    func pause() {
        if let player = audioPlayer, let song = currentSong {
            player.pause()
            delegate?.playerPausedSong(song)
            setupRemoteCenterInfo()
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentSong = nil
        delegate?.playerStopped()
        clearRemoteCenterInfo()
        stopTimer()
    }
    
    func playNextSong() {
        let songs: [Song]
        
        if shuffleState {
            songs = shuffleArray
        } else {
            songs = songsList
        }
        
        guard let currentSong = currentSong else { return }
        
        if let nextSong = songs.after(item: currentSong) {
            playSong(nextSong)
        } else {
            let song = songs.isEmpty ? currentSong : songs.first!
            playSong(song)
            pause()
        }
    }
    
    func playPreviousSong() {
        let songs: [Song]
        
        if shuffleState {
            songs = shuffleArray
        } else {
            songs = songsList
        }
        
        guard let currentSong = currentSong else { return }
        
        if let prevSong = songs.before(item: currentSong) {
            playSong(prevSong)
        } else {
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
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterrupted), name: .AVAudioSessionInterruption, object: nil)
    }
    
    @objc private func audioSessionInterrupted() {
        pause()
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
