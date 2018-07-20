//
//  SpotlightManager.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 18.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

enum SpotlightDomainId: String {
    
    case songs
    case albums
    case playlists
}

final class SpotlightManager {
    
    class func indexAllData() {
        DispatchQueue.global(qos: .userInitiated).async {
            var searchableItems = [CSSearchableItem]()
            
            let allSongs = Library.main.allSongs
            
            for song in allSongs {
                searchableItems.append(self.searchableItem(for: song))
            }
            
            let allAlbums = Library.main.allAlbums
            
            for album in allAlbums {
                searchableItems.append(self.searchableItem(for: album))
            }
            
            let allPlaylists = Library.main.allPlaylists
            
            for playlist in allPlaylists {
                searchableItems.append(self.searchableItem(for: playlist))
            }
            
            self.indexSearchableItems(searchableItems)
        }
    }
    
    class func removeAllData() {
        DispatchQueue.global(qos: .userInitiated).async {
            CSSearchableIndex.default().deleteAllSearchableItems { error in
                
            }
        }
    }
    
    private class func searchableItem(for song: Song) -> CSSearchableItem {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        
        attributeSet.title = song.title
        attributeSet.keywords = ["songs", "music", "player"]
        
        if let album = song.album {
            attributeSet.contentDescription = "\(album.artist) - \(album.title)"
            if let artwork = album.artwork {
                attributeSet.thumbnailData = thumbnailData(from: artwork)
            }
        }
        
        let domainId = SpotlightDomainId.songs.rawValue
        let uniqueId = "\(domainId):\(song.id)"
        
        return CSSearchableItem(uniqueIdentifier: uniqueId, domainIdentifier: domainId, attributeSet: attributeSet)
    }
    
    private class func searchableItem(for album: Album) -> CSSearchableItem {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        
        attributeSet.title = album.title
        attributeSet.contentDescription = album.artist
        attributeSet.keywords = ["albums", "music", "player"]
        
        if let artwork = album.artwork {
            attributeSet.thumbnailData = thumbnailData(from: artwork)
        }
        
        let domainId = SpotlightDomainId.albums.rawValue
        let uniqueId = "\(domainId):\(album.id)"
        
        return CSSearchableItem(uniqueIdentifier: uniqueId, domainIdentifier: domainId, attributeSet: attributeSet)
    }
    
    private class func searchableItem(for playlist: Playlist) -> CSSearchableItem {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
        
        attributeSet.title = playlist.title
        attributeSet.keywords = ["playlists", "music", "player"]
        
        if let artwork = playlist.artwork {
            attributeSet.thumbnailData = thumbnailData(from: artwork)
        }
        
        let domainId = SpotlightDomainId.playlists.rawValue
        let uniqueId = "\(domainId):\(playlist.id)"
        
        return CSSearchableItem(uniqueIdentifier: uniqueId, domainIdentifier: domainId, attributeSet: attributeSet)
    }
    
    private class func indexSearchableItems(_ items: [CSSearchableItem]) {
        DispatchQueue.global(qos: .userInitiated).async {
            CSSearchableIndex.default().indexSearchableItems(items) { error in
                if error == nil {
                    print("Searchable items were indexed successfully")
                } else {
                    print(error!.localizedDescription)
                }
            }
        }
    }
    
    private class func removeSearchableItem(with id: String) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id]) { error in
            print(error ?? "no error")
        }
    }
    
    class func indexSongs(_ songs: [Song]) {
        var searchableItems = [CSSearchableItem]()
        for song in songs {
            searchableItems.append(self.searchableItem(for: song))
        }
        self.indexSearchableItems(searchableItems)
    }
    
    class func indexSong(_ song: Song) {
        let searchableItem = self.searchableItem(for: song)
        self.indexSearchableItems([searchableItem])
    }
    
    class func indexAlbum(_ album: Album) {
        let searchableItem = self.searchableItem(for: album)
        self.indexSearchableItems([searchableItem])
    }
    
    class func indexPlaylist(_ playlist: Playlist) {
        let searchableItem = self.searchableItem(for: playlist)
        self.indexSearchableItems([searchableItem])
    }
    
    class func removeSong(_ song: Song) {
        let domainId = SpotlightDomainId.songs.rawValue
        let uniqueId = "\(domainId):\(song.id)"
        self.removeSearchableItem(with: uniqueId)
    }
    
    class func removeAlbum(_ album: Album) {
        let domainId = SpotlightDomainId.albums.rawValue
        let uniqueId = "\(domainId):\(album.id)"
        self.removeSearchableItem(with: uniqueId)
    }
    
    class func removePlaylist(_ playlist: Playlist) {
        let domainId = SpotlightDomainId.playlists.rawValue
        let uniqueId = "\(domainId):\(playlist.id)"
        self.removeSearchableItem(with: uniqueId)
    }
    
    private class func thumbnailData(from image: UIImage) -> Data? {
        let size: CGSize
        switch currentDevice {
        case .iPhone5 : size = CGSize(width: 40, height: 40)
        case .iPhone6 : size = CGSize(width: 120, height: 120)
        case .iPhone6Plus, .iPhoneX : size = CGSize(width: 180, height: 180)
        }
        return image.resize(to: size).imageData()
    }
}
