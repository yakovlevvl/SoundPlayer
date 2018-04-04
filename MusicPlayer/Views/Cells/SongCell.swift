//
//  SongCell.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 09.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class BaseSongCell: UICollectionViewCell {
    
    private let artwork: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 46, height: 46)
        imageView.image = UIImage(named: "LibraryIcon")
        imageView.tintColor = UIColor(hex: "D0021B")
        imageView.contentMode = .center
        return imageView
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 28
        label.font = UIFont(name: Fonts.general, size: 20)
        return label
    }()
    
    static let reuseId = "SongCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews() {
        contentView.addSubview(artwork)
        contentView.addSubview(titleLabel)
        
        backgroundColor = .clear
        contentView.backgroundColor = .white
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        setupShadow()
        
        layoutViews()
    }
    
    fileprivate func layoutViews() {
        artwork.frame.origin.x = 8
        artwork.center.y = contentView.center.y
        
        titleLabel.center.y = contentView.center.y
        titleLabel.frame.origin.x = artwork.frame.maxX + 5
        titleLabel.frame.size.width = frame.width - titleLabel.frame.minX - 20
    }
    
    private func setupShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.shadowOpacity = 0.08  //0.12 0.08
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor(hex: "D0021B").cgColor //UIColor.gray.cgColor
        layer.shadowRadius = 15
    }
    
    func setup(for song: Song) {
        titleLabel.text = song.title
//        if flag == 1 {
//            artwork.frame.origin.x = 16
//            titleLabel.frame.origin.x = artwork.frame.maxX + 16
//            artwork.contentMode = .scaleAspectFit
//            artwork.image = UIImage(named: "ExampleArtwork")!
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class SongCell: BaseSongCell {
    
    weak var delegate: SongCellDelegate?
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 42, height: 58)
        button.setImage(UIImage(named: "MoreIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(moreButton)
        moreButton.addTarget(self, action: #selector(tapMoreButton), for: .touchUpInside)
    }
    
    override func layoutViews() {
        super.layoutViews()
        
        moreButton.center.y = contentView.center.y
        moreButton.frame.origin.x = frame.width - moreButton.frame.width - 3
        
        titleLabel.frame.size.width = moreButton.frame.minX - titleLabel.frame.minX + 1
    }
    
    @objc private func tapMoreButton() {
        delegate?.tapMoreButton(self)
    }
}

protocol SongCellDelegate: class {
    
    func tapMoreButton(_ cell: SongCell)
}

final class NewAlbumSongCell: BaseSongCell {
    
    weak var delegate: NewAlbumSongCellDelegate?
    
    private let removeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 40, height: 40)
        button.setImage(UIImage(named: "StopLoadIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(removeButton)
        removeButton.addTarget(self, action: #selector(tapRemoveButton), for: .touchUpInside)
    }
    
    override func layoutViews() {
        super.layoutViews()
        
        removeButton.center.y = contentView.center.y
        removeButton.frame.origin.x = frame.width - removeButton.frame.width - 9
        
        titleLabel.frame.size.width = removeButton.frame.minX - titleLabel.frame.minX + 1
    }
    
    @objc private func tapRemoveButton() {
        delegate?.tapRemoveButton(self)
    }
}

protocol NewAlbumSongCellDelegate: class {
    
    func tapRemoveButton(_ cell: NewAlbumSongCell)
}

final class AddSongCell: BaseSongCell {
    
    weak var delegate: AddSongCellDelegate?
    
    private let addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 46, height: 46)
        button.setImage(UIImage(named: "PlusIcon"), for: .normal)
        button.tintColor = UIColor(hex: "D0021B")
        button.contentMode = .center
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(addButton)
        addButton.addTarget(self, action: #selector(tapAddButton), for: .touchUpInside)
    }
    
    override func layoutViews() {
        super.layoutViews()
        
        addButton.center.y = contentView.center.y
        addButton.frame.origin.x = frame.width - addButton.frame.width - 7
        
        titleLabel.frame.size.width = addButton.frame.minX - titleLabel.frame.minX + 1
    }
    
    func setup(for song: Song, isAdded: Bool) {
        titleLabel.text = song.title
        addButton.tintColor = isAdded ? .black : UIColor(hex: "D0021B")
        addButton.setImage(UIImage(named: isAdded ? "Checkmark" : "PlusIcon"), for: .normal)
    }
    
    @objc private func tapAddButton() {
        delegate?.tapAddButton(self)
    }
}

protocol AddSongCellDelegate: class {
    
    func tapAddButton(_ cell: AddSongCell)
}

