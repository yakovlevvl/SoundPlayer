//
//  NewAlbumView.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 16.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class NewPlaylistView: UICollectionReusableView {
    
    weak var delegate: NewPlaylistViewDelegate?
    
    private let artworkView: ArtworkView = {
        let imageView = ArtworkView()
        let height = UIProperties.CompilationView.artworkHeight
        imageView.frame.size = CGSize(width: height, height: height)
        return imageView
    }()
    
    fileprivate let titleField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 26
        textField.placeholder = "Title"
        textField.borderStyle = .none
        textField.minimumFontSize = 19
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.adjustsFontSizeToFitWidth = true
        textField.font = Fonts.compilationViewTitleFont
        return textField
    }()
    
    private let plusButton: RoundButton = {
        let button = RoundButton(type: .custom)
        let height = UIProperties.CompilationView.playButtonHeight
        button.frame.size = CGSize(width: height, height: height)
        button.backgroundColor = Colors.roundButtonColor
        button.setImage(UIImage(named: "PlusIcon"))
        button.setShadowColor(Colors.red)
        button.setShadowOpacity(0.5)
        button.setShadowRadius(10)
        button.tintColor = .white
        return button
    }()
    
    private let addMusicButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Add Songs", for: .normal)
        button.titleLabel!.font = Fonts.addMusicButtonFont
        button.frame.size = CGSize(width: 100, height: 50)
        return button
    }()
    
    private let addArtworkButton: RoundButton = {
        let button = RoundButton(type: .custom)
        let height = UIProperties.CompilationView.moreButtonHeight
        button.frame.size = CGSize(width: height, height: height)
        button.backgroundColor = Colors.roundButtonColor
        button.setImage(UIImage(named: "PlusMiniIcon"))
        button.tintColor = .white
        return button
    }()
    
    static let reuseId = "NewPlaylistView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }
    
    fileprivate func setupViews() {
        backgroundColor = .clear
        
        addSubview(titleField)
        addSubview(artworkView)
        
        addSubview(plusButton)
        addSubview(addMusicButton)
        addSubview(addArtworkButton)
        
        plusButton.addTarget(self, action: #selector(tapAddMusicButton), for: .touchUpInside)
        addMusicButton.addTarget(self, action: #selector(tapAddMusicButton), for: .touchUpInside)
        addArtworkButton.addTarget(self, action: #selector(tapAddArtworkButton), for: .touchUpInside)
        
        titleField.addTarget(self, action: #selector(titleFieldChangedText), for: .editingChanged)
        titleField.addTarget(titleField, action: #selector(resignFirstResponder), for: .editingDidEndOnExit)
    }
    
    fileprivate func layoutViews() {
        artworkView.frame.origin = CGPoint(x: 20, y: UIProperties.CompilationView.artworkTopInset + 1)
        
        titleField.frame.origin.y = artworkView.frame.minY + 8
        titleField.frame.origin.x = artworkView.frame.maxX + 20
        titleField.frame.size.width = frame.width - titleField.frame.minX - 20
        
        plusButton.frame.origin = CGPoint(x: 32, y: artworkView.frame.maxY + UIProperties.CompilationView.playButtonTopInset)
        addMusicButton.frame.origin.x = plusButton.frame.maxX + 10
        addMusicButton.center.y = plusButton.center.y
        
        addArtworkButton.center = CGPoint(x: artworkView.frame.maxX - 12, y: artworkView.frame.maxY - 12)
    }
    
    @objc fileprivate func titleFieldChangedText() {
        delegate?.titleFieldChangedText(titleField.text!)
    }
    
    @objc fileprivate func tapAddArtworkButton() {
        delegate?.didTapAddArtworkButton()
    }
    
    @objc fileprivate func tapAddMusicButton() {
        delegate?.didTapAddMusicButton()
    }
    
    func setupTitle(_ title: String) {
        titleField.text = title
    }
    
    func setupArtworkImage(_ image: UIImage?) {
        artworkView.setArtwork(image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol NewPlaylistViewDelegate: class {
    
    func didTapAddMusicButton()
    func didTapAddArtworkButton()
    func titleFieldChangedText(_ text: String)
}

final class NewAlbumView: NewPlaylistView {
    
    private let artistField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 26
        textField.placeholder = "Artist"
        textField.borderStyle = .none
        textField.minimumFontSize = 19
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.adjustsFontSizeToFitWidth = true
        textField.font = Fonts.compilationViewTitleFont
        return textField
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(artistField)
        artistField.addTarget(self, action: #selector(artistFieldChangedText), for: .editingChanged)
        artistField.addTarget(artistField, action: #selector(resignFirstResponder), for: .editingDidEndOnExit)
    }
    
    override func layoutViews() {
        super.layoutViews()
        artistField.frame.origin.x = titleField.frame.origin.x
        artistField.frame.origin.y = titleField.frame.maxY + 18
        artistField.frame.size.width = titleField.frame.width
    }
    
    @objc fileprivate func artistFieldChangedText() {
        (delegate as? NewAlbumViewDelegate)?.artistFieldChangedText(artistField.text!)
    }
    
    func setupArtist(_ artist: String) {
        artistField.text = artist
    }
}

protocol NewAlbumViewDelegate: NewPlaylistViewDelegate {
    
    func artistFieldChangedText(_ text: String)
}

