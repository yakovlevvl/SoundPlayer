//
//  NewAlbumView.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 16.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class NewAlbumView: UICollectionReusableView {
    
    weak var delegate: NewAlbumViewDelegate?
    
    private let artworkView: ArtworkView = {
        let imageView = ArtworkView()
        imageView.frame.size = CGSize(width: 110, height: 110)
        return imageView
    }()
    
    private let titleField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 26
        textField.placeholder = "Title"
        textField.borderStyle = .none
        textField.minimumFontSize = 19
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.adjustsFontSizeToFitWidth = true
        textField.font = UIFont(name: Fonts.general, size: 20)
        return textField
    }()
    
    private let artistField: UITextField = {
        let textField = UITextField()
        textField.frame.size.height = 26
        textField.placeholder = "Artist"
        textField.borderStyle = .none
        textField.minimumFontSize = 19
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.adjustsFontSizeToFitWidth = true
        textField.font = UIFont(name: Fonts.general, size: 20)
        return textField
    }()
    
    private let plusButton: RoundButton = {
        let button = RoundButton(type: .custom)
        button.frame.size = CGSize(width: 54, height: 54)
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
        button.titleLabel!.font = UIFont(name: Fonts.general, size: 19)
        button.frame.size = CGSize(width: 100, height: 50)
        return button
    }()
    
    private let addArtworkButton: RoundButton = {
        let button = RoundButton(type: .custom)
        button.frame.size = CGSize(width: 34, height: 34)
        button.backgroundColor = Colors.roundButtonColor
        button.setImage(UIImage(named: "PlusMiniIcon"))
        button.tintColor = .white
        return button
    }()
    
    static let reuseId = "NewAlbumView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        addSubview(titleField)
        addSubview(artistField)
        addSubview(artworkView)
        
        addSubview(plusButton)
        addSubview(addMusicButton)
        addSubview(addArtworkButton)
        
        plusButton.addTarget(self, action: #selector(tapAddMusicButton), for: .touchUpInside)
        addMusicButton.addTarget(self, action: #selector(tapAddMusicButton), for: .touchUpInside)
        addArtworkButton.addTarget(self, action: #selector(tapAddArtworkButton), for: .touchUpInside)
        
        titleField.addTarget(titleField, action: #selector(resignFirstResponder), for: .editingDidEndOnExit)
        artistField.addTarget(artistField, action: #selector(resignFirstResponder), for: .editingDidEndOnExit)
        
        titleField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        artistField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        layoutViews()
    }
    
    private func layoutViews() {
        artworkView.frame.origin = CGPoint(x: 20, y: 2)
        
        titleField.frame.origin.y = artworkView.frame.minY + 8
        titleField.frame.origin.x = artworkView.frame.maxX + 20
        titleField.frame.size.width = frame.width - titleField.frame.minX - 20
        
        artistField.frame.origin.x = titleField.frame.origin.x
        artistField.frame.origin.y = titleField.frame.maxY + 18
        artistField.frame.size.width = titleField.frame.width
        
        plusButton.frame.origin = CGPoint(x: 32, y: artworkView.frame.maxY + 30)
        addMusicButton.frame.origin.x = plusButton.frame.maxX + 10
        addMusicButton.center.y = plusButton.center.y
        
        addArtworkButton.center = CGPoint(x: artworkView.frame.maxX - 12, y: artworkView.frame.maxY - 12)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == titleField {
            delegate?.titleFieldChangedText(textField.text!)
        }
        if textField == artistField {
            delegate?.artistFieldChangedText(textField.text!)
        }
    }
    
    @objc private func tapAddMusicButton() {
        delegate?.didTapAddMusicButton()
    }
    
    @objc private func tapAddArtworkButton() {
        delegate?.didTapAddArtworkButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewAlbumView {
    
    func setupTitle(_ title: String) {
        titleField.text = title
    }
    
    func setupArtist(_ artist: String) {
        artistField.text = artist
    }
    
    func setupArtworkImage(_ image: UIImage?) {
        artworkView.setArtwork(image)
    }
}

protocol NewAlbumViewDelegate: class {
    
    func didTapAddMusicButton()
    func didTapAddArtworkButton()
    func titleFieldChangedText(_ text: String)
    func artistFieldChangedText(_ text: String)
}
