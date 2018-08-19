//
//  Compilation.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 04.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class Compilation: Object {
    
    @objc dynamic var title = ""
    @objc private dynamic var artworkSubpath: String?
    @objc private(set) dynamic var creationDate = Date()
    
    @objc private(set) dynamic var id = UUID().uuidString
    
    var artwork: UIImage? {
        get {
            guard let path = artworkPath else { return nil }
            let url = URL(fileURLWithPath: path)
            guard let data = try? Data(contentsOf: url) else { return nil }
            return UIImage(data: data, scale: UIScreen.main.scale)
        }
        set {
            removeArtwork()
            guard let image = newValue else {
                return
            }
            let fileManager = FileManager.default
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let artworksUrl = documentsUrl.appendingPathComponent("Artworks", isDirectory: true)
            if !fileManager.directoryExists(artworksUrl.path) {
                try! fileManager.createDirectory(atPath: artworksUrl.path, withIntermediateDirectories: true)
            }
            let pathComponent = UUID().uuidString + ".png"
            let artworkUrl = artworksUrl.appendingPathComponent(pathComponent)
            
            guard let data = UIImagePNGRepresentation(image) else { return }
            
            do {
                try data.write(to: artworkUrl)
                artworkSubpath = pathComponent
            } catch {
                if fileManager.fileExists(atPath: artworkUrl.path) {
                    try? fileManager.removeItem(atPath: artworkUrl.path)
                }
            }
        }
    }
    
    func getArtworkAsync(completion: @escaping (UIImage?) -> ()) {
        guard let path = artworkPath else { return completion(nil) }
        DispatchQueue.global(qos: .userInteractive).async {
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                let artwork = UIImage(data: data, scale: UIScreen.main.scale) else {
                    return DispatchQueue.main.async { completion(nil) }
            }
            DispatchQueue.main.async {
                completion(artwork)
            }
        }
    }
    
    private func removeArtwork() {
        guard let path = artworkPath else {
            return
        }
        artworkSubpath = nil
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
    }
    
    private var artworkPath: String? {
        guard let subpath = artworkSubpath else {
            return nil
        }
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let artworkUrl = documentsUrl.appendingPathComponent("Artworks").appendingPathComponent(subpath)
        return artworkUrl.path
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
