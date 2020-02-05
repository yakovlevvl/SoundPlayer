//
//  SongActions.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 08.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

protocol SongBaseActions: class {
    
    var transitionManager: VerticalTransitionManager { get }
    
    func showActions(for song: Song, at indexPath: IndexPath)
    func renameSong(_ song: Song, with name: String, at indexPath: IndexPath)
    func showAlertViewForRenameSong(_ song: Song, at indexPath: IndexPath)
}

extension SongBaseActions where Self: UIViewController {
    
    func showAlertViewForRenameSong(_ song: Song, at indexPath: IndexPath) {
        let alertVC = AlertController(message: "Rename Song")
        alertVC.includeTextField = true
        alertVC.allowEmptyTextField = false
        alertVC.showClearButton = true
        alertVC.textFieldPlaceholder = "Name"
        alertVC.textFieldText = song.title
        alertVC.font = UIFont(name: Fonts.general, size: 21)!
        let cancelAction = Action(title: "Cancel", type: .cancel)
        let renameAction = Action(title: "Save", type: .normal) { 
            let songName = alertVC.textFieldText!
            self.renameSong(song, with: songName, at: indexPath)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(renameAction)
        alertVC.present()
    }
}

protocol SongActions: SongBaseActions {
    
    func removeSong(_ song: Song, at indexPath: IndexPath)
    func selectAlbum(for song: Song)
    func selectPlaylist(for song: Song)
}

extension SongActions where Self: UIViewController {
    
    func showActions(for song: Song, at indexPath: IndexPath) {
        let actionSheet = RoundActionSheet()
        let renameAction = Action(title: "Rename", type: .normal) {
            self.showAlertViewForRenameSong(song, at: indexPath)
        }
        let addToAlbumAction = Action(title: "Add to Album", type: .normal) {
            self.selectAlbum(for: song)
        }
        let addToPlaylistAction = Action(title: "Add to Playlist", type: .normal) {
            self.selectPlaylist(for: song)
        }
        let removeAction = Action(title: "Delete from Library", type: .destructive) {
            self.removeSong(song, at: indexPath)
        }
        actionSheet.addAction(renameAction)
        if song.album == nil {
            actionSheet.addAction(addToAlbumAction)
        }
        actionSheet.addAction(addToPlaylistAction)
        actionSheet.addAction(removeAction)
        actionSheet.present()
    }
    
    func selectAlbum(for song: Song) {
        let selectAlbumVC = SelectAlbumVC()
        selectAlbumVC.song = song
        selectAlbumVC.modalPresentationStyle = .fullScreen
        selectAlbumVC.transitioningDelegate = transitionManager
        present(selectAlbumVC, animated: true)
    }
    
    func selectPlaylist(for song: Song) {
        let selectPlaylistVC = SelectPlaylistVC()
        selectPlaylistVC.songs = [song]
        selectPlaylistVC.modalPresentationStyle = .fullScreen
        selectPlaylistVC.transitioningDelegate = transitionManager
        present(selectPlaylistVC, animated: true)
    }
}

protocol AlbumSongActions: SongBaseActions {
    
    var album: Album! { get set }
    
    func removeSong(_ song: Song, at indexPath: IndexPath)
    func removeSongFromAlbum(_ song: Song, at indexPath: IndexPath)
    func selectPlaylist(for song: Song)
}

extension AlbumSongActions where Self: UIViewController {
    
    func showActions(for song: Song, at indexPath: IndexPath) {
        let actionSheet = RoundActionSheet()
        let albumRemoveAction = Action(title: "Delete from Album", type: .normal) {
            self.removeSongFromAlbum(song, at: indexPath)
        }
        let renameAction = Action(title: "Rename", type: .normal) {
            self.showAlertViewForRenameSong(song, at: indexPath)
        }
        let addToPlaylistAction = Action(title: "Add to Playlist", type: .normal) {
            self.selectPlaylist(for: song)
        }
        let removeAction = Action(title: "Delete from Library", type: .destructive) {
            self.removeSong(song, at: indexPath)
        }
        actionSheet.addAction(renameAction)
        actionSheet.addAction(addToPlaylistAction)
        if album.songs.count > 1 {
            actionSheet.addAction(albumRemoveAction)
            actionSheet.addAction(removeAction)
        }
        actionSheet.present()
    }
    
    func selectPlaylist(for song: Song) {
        let selectPlaylistVC = SelectPlaylistVC()
        selectPlaylistVC.songs = [song]
        selectPlaylistVC.modalPresentationStyle = .fullScreen
        selectPlaylistVC.transitioningDelegate = transitionManager
        present(selectPlaylistVC, animated: true)
    }
}

protocol PlaylistSongActions: SongBaseActions {
    
    var playlist: Playlist! { get set }
    
    func removeSongFromPlaylist(_ song: Song, at indexPath: IndexPath)
}

extension PlaylistSongActions where Self: UIViewController {
    
    func showActions(for song: Song, at indexPath: IndexPath) {
        let actionSheet = RoundActionSheet()
        let playlistRemoveAction = Action(title: "Delete from Playlist", type: .normal) {
            self.removeSongFromPlaylist(song, at: indexPath)
        }
        let renameAction = Action(title: "Rename", type: .normal) {
            self.showAlertViewForRenameSong(song, at: indexPath)
        }
        actionSheet.addAction(renameAction)
        if playlist.songs.count > 1 {
            actionSheet.addAction(playlistRemoveAction)
        }
        actionSheet.present()
    }
}


