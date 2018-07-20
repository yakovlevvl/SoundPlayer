//
//  SwitchSettingCell.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 18.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

protocol SwitchSettingCellDelegate: class {
    
    func switchValueChanged(isOn: Bool, cell: SwitchSettingCell)
}

final class SwitchSettingCell: SettingCell {
    
    weak var delegate: SwitchSettingCellDelegate?
    
    private let switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = Colors.switchColor
        return switcher
    }()
    
    override class var reuseId: String {
        return "SwitchSettingCell"
    }
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(switcher)
        switcher.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    override func layoutViews() {
        switcher.center.y = contentView.center.y
        switcher.frame.origin.x = contentView.frame.width - switcher.frame.width - 18
        
        titleLabel.center.y = contentView.center.y
        titleLabel.frame.origin.x = 30
        titleLabel.frame.size.width = switcher.frame.minX - titleLabel.frame.minX - 10
    }
    
    @objc private func switchValueChanged() {
        delegate?.switchValueChanged(isOn: switcher.isOn, cell: self)
    }
    
    func setSwitchOn(_ on: Bool) {
        switcher.setOn(on, animated: false)
    }
}
