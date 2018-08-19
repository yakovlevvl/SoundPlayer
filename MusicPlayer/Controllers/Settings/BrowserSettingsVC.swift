//
//  BrowserSettingsVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 20.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class BrowserSettingsVC: SettingsBaseVC {
    
    private enum BrowserSettings: String {
        
        case clearHistory = "Clear History"
        
        case clearCookiesAndData = "Clear Cookies and Data"
    }
    
    private let settingsGroups: [SettingsGroup<BrowserSettings>] = [
        SettingsGroup(settings: [.clearHistory, .clearCookiesAndData])]
    
    override func setupViews() {
        super.setupViews()
        topBar.title = "Browser"
    }
}

extension BrowserSettingsVC {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return settingsGroups.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingsGroups[section].settings.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let setting = settingsGroups[indexPath.section].settings[indexPath.item]
        switch setting {
        case .clearHistory, .clearCookiesAndData :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.reuseId, for: indexPath) as! SettingCell
            cell.setupTitle(setting.rawValue)
            cell.scaleByTap = true
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: SettingDescriptionView.reuseId, for: indexPath) as! SettingDescriptionView
        if let description = settingsGroups[indexPath.section].description {
            view.setupDescription(description)
        }
        return view
    }
}

extension BrowserSettingsVC {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let setting = settingsGroups[indexPath.section].settings[indexPath.item]
        switch setting {
        case .clearHistory :
            BrowserHistoryManager().clearHistory()
        case .clearCookiesAndData :
            BrowserDataManager.clearCookiesAndData()
            SettingsManager.browserNeedReset = true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let description = settingsGroups[section].description else {
            return .zero
        }
        let textSize = description.textSizeForMaxWidth(view.frame.width - 2*SettingDescriptionView.textHorizontalInset, font: Fonts.settingDescriptionViewFont)
        return CGSize(width: view.frame.width, height: textSize.height + 2*SettingDescriptionView.textVerticalInset)
    }
}
