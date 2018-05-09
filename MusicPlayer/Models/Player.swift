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

class Player: NSObject {
    
    static let main = Player()
    
    weak var delegate: PlayerDelegate?
    
    private let audioSession = AVAudioSession.sharedInstance()
    
    private var audioPlayer: AVAudioPlayer?
    
    var songsList = [Song]() {
        didSet {
            if songsList != oldValue {
                if shuffleState {
                    setupShuffleArray()
                }
            }
        }
    } 
    
    private var shuffleArray = [Song]()
    
    private(set) var currentSong: Song!
    
    private var timer: Timer!
    
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
    
    var volume: Float {
        get {
            return audioSession.outputVolume
        }
        set {
            audioPlayer?.volume = newValue
        }
    }
    
    var currentTime: Float {
        get {
            return Float(audioPlayer?.currentTime ?? 0)
        }
        set {
            DispatchQueue.global().async {
                self.audioPlayer?.currentTime = TimeInterval(newValue)
            }
        }
    }
    
    var currentDuration: Float {
        return Float(audioPlayer?.duration ?? 0)
    }
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    private var playingObservation: NSKeyValueObservation?
    
    private override init() {
        super.init()
        setupRemoteCenterCommands()
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterapted), name: .AVAudioSessionInterruption, object: nil)
    }
    
    func playSong(_ song: Song) {
        currentSong = song
        prepareSong()
    }
    
    private func prepareSong() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: currentSong.url)
        } catch {
            stop()
            clearRemoteCenterInfo()
            delegate?.playerFailedSong(currentSong)
            return
        }
        
        audioPlayer?.delegate = self
        playSong()
    }
    
    private func playSong() {
        play()
        startTimer()
        resetPlaybackTime()
        setupRemoteCenterInfo()
    }
    
    private func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(songCurrentTimeChanged), userInfo: nil, repeats: true)
            timer.fire()
        }
    }
    
    private func stopTimer() {
        timer.invalidate()
    }
    
    private func setupShuffleArray() {
        if songsList.isEmpty { return }
        shuffleArray = songsList.shuffled()
        if currentSong != nil {
            if let index = shuffleArray.index(of: currentSong) {
                shuffleArray.remove(at: index)
                shuffleArray.insert(currentSong, at: 0)
            }
        }
    }
    
    func playSongsList(_ songs: [Song]) {
        if !songs.isEmpty {
            repeatState = false
            shuffleState = false
            songsList = songs
            playSong(songsList.first!)
        }
    }
    
    func shuffleAndPlaySongsList(_ songs: [Song]) {
        if !songs.isEmpty {
            currentSong = nil
            songsList = songs
            shuffleState = true
            playSong(shuffleArray.first!)
        }
    }
    
    @objc private func songCurrentTimeChanged() {
        if isPlaying {
            delegate?.playerUpdatedSongCurrentTime(currentTime: currentTime)
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentSong = nil
        delegate?.playerStopped()
    }
    
    func play() {
        if audioPlayer != nil {
            audioPlayer?.play()
            delegate?.playerResumedSong(currentSong)
        }
    }
    
    func pause() {
        if audioPlayer != nil {
            audioPlayer?.pause()
            delegate?.playerPausedSong(currentSong)
        }
    }
    
    private func setupRemoteCenterInfo() {
        let title = currentSong.title
        var nowPlayingInfo = [MPMediaItemPropertyTitle : title] as [String : Any]
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer?.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer?.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1 : 0
        
        if let album = currentSong.album?.title {
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        }
        if let artist = currentSong.album?.artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
        if let artwork = currentSong.artwork {
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
            self.setupRemoteCenterInfo()
            return .success
        }
        remoteCenter.pauseCommand.addTarget { event in
            self.pause()
            self.setupRemoteCenterInfo()
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
            self.audioPlayer?.currentTime = (event as! MPChangePlaybackPositionCommandEvent).positionTime
            self.setupRemoteCenterInfo()
            return .success
        }
        remoteCenter.togglePlayPauseCommand.addTarget { event in
            if self.isPlaying {
                self.pause()
            } else {
                self.play()
            }
            self.setupRemoteCenterInfo()
            return .success
        }
    }
    
    private func clearRemoteCenterInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func resetPlaybackTime() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = nil
    }
    
    func playNextSong() {
        let songs: [Song]
        
        if shuffleState {
            songs = shuffleArray
        } else {
            songs = songsList
        }
        
        guard let nextSong = songs.next(item: currentSong) else {
            if !songs.isEmpty {
                let song = songs.first!
                playSong(song)
                pause()
            } else {
                playSong(currentSong)
                pause()
            }
            setupRemoteCenterInfo()
            return
        }
        playSong(nextSong)
    }

    func playPreviousSong() {
        let songs: [Song]
        
        if shuffleState {
            songs = shuffleArray
        } else {
            songs = songsList
        }
        
        guard let prevSong = songs.prev(item: currentSong) else {
            playSong(currentSong)
            return
        }
        playSong(prevSong)
    }
    
    @objc private func audioSessionInterapted() {
        pause()
    }

}

extension Player: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch (repeatState, shuffleState) {
        case (false, false) : playNextSong()
        case (true, true) : playSong(currentSong)
        case (true, false) : playSong(currentSong)
        case (false, true) : playNextSong()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur")
    }
}
