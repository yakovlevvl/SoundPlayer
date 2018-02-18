//
//  Library.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class Library {
    
    static let main = Library()
    
    private let realm = try! Realm()
    
    private init() {}
    
    func getSongs() -> Results<Song> {
        return realm.objects(Song.self)
    }
    
    func getAlbums() -> Results<Album> {
        return realm.objects(Album.self)
    }
    
    func addSong(_ song: Song) {
        DispatchQueue.global(qos: .userInteractive).async {
            let realm = try! Realm()
            try! realm.write {
                realm.add(song)
            }
            realm.refresh()
        }
    }
    
    func addAlbum(_ album: Album) {
        try! realm.write {
            realm.add(album)
        }
    }
    
    func removeSong(_ song: Song) {
        try! realm.write {
            realm.delete(song)
        }
    }
    
    func removeAlbum(_ album: Album) {
        try! realm.write {
            realm.delete(album)
        }
    }
    
}
