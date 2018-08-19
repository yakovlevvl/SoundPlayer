//
//  SongDownloadCell.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 07.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SongDownloadCell: UICollectionViewCell {
    
    weak var delegate: SongDownloadCellDelegate?
    
    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 30, height: 30)
        imageView.image = UIImage(named: "LibraryIcon")
        imageView.contentMode = .center
        imageView.tintColor = .black
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 28
        label.font = Fonts.songDownloadCellTitleFont
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 28
        label.font = Fonts.songDownloadCellProgressFont
        return label
    }()
    
    private let progressView: ProgressView = {
        let view = ProgressView()
        view.isUserInteractionEnabled = false
        view.progressColor = UIColor(hex: "d7e6f9")
        return view
    }()
    
    private let controlButton: DownloadControlButton = {
        let button = DownloadControlButton(type: .custom)
        button.frame.size = CGSize(width: 30, height: 30)
        return button
    }()
    
    static let reuseId = "SongDownloadCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(progressLabel)
        contentView.addSubview(controlButton)
        contentView.insertSubview(progressView, at: 0)
        
        controlButton.addTarget(self, action: #selector(tapControlButton), for: .touchUpInside)
        
        backgroundColor = .clear
        contentView.backgroundColor = .white
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        setupShadow()
        
        layoutViews()
    }
    
    private func layoutViews() {
        progressView.frame = contentView.bounds
        
        icon.center.y = contentView.center.y
        controlButton.center.y = contentView.center.y
        titleLabel.center.y = (contentView.frame.height/3).rounded() - 1
        progressLabel.center.y = 2*(contentView.frame.height/3).rounded() + 3
        
        icon.frame.origin.x = 12
        controlButton.frame.origin.x = frame.width - controlButton.frame.width - 14
        
        titleLabel.frame.origin.x = icon.frame.maxX + 10
        progressLabel.frame.origin.x = titleLabel.frame.origin.x
        
        titleLabel.frame.size.width = controlButton.frame.minX - titleLabel.frame.minX - 10
        progressLabel.frame.size.width = titleLabel.frame.width
    }
    
    private func setupShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.shadowOpacity = 0.12
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 7
    }
    
    @objc private func tapControlButton() {
        if controlButton.controlState == .remove {
            delegate?.tapRemoveButton(self)
        } else {
            delegate?.tapReloadButton(self)
        }
    }
    
    func setup(for download: SongDownload) {
        titleLabel.text = download.title
        
        switch download.status {
            
        case .downloaded : progressLabel.text = download.totalSize
            controlButton.controlState = .remove
            icon.tintColor = UIColor(hex: "D0021B")
            
        case .downloading : progressLabel.text = download.progress.description
            controlButton.controlState = .remove
            progressView.setupProgressWithoutAnimation(with: download.progress.value)
            
        case .failed : progressLabel.text = "Failed"
            progressLabel.textColor = .red
            controlButton.controlState = .reload
            
        case .paused : progressLabel.text = "Paused " + download.progress.description
            controlButton.controlState = .remove
            progressView.setupProgressWithoutAnimation(with: download.progress.value)
            
        case .preparing : progressLabel.text = "Preparing..."
            controlButton.controlState = .remove
        }
    }
    
    func update(with progress: Progress) {
        progressView.progress = progress.value
        progressLabel.text = progress.description
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        progressView.reset()
        icon.tintColor = .black
        progressLabel.textColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol SongDownloadCellDelegate: class {
    
    func tapRemoveButton(_ cell: SongDownloadCell)
    func tapReloadButton(_ cell: SongDownloadCell)
    
}

