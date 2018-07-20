//
//  SearchSettingsVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 15.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SearchSettingsVC: SettingsBaseVC {
    
    private enum SearchSettings: String {
        
        case enableSpotlight = "Enable Spotlight"
        
        case updateSpotlightIndex = "Update Spotlight index"
    }
    
    private let settingsGroups: [SettingsGroup<SearchSettings>] = [
        SettingsGroup(settings: [.enableSpotlight], description: "Enable Spotlight indexing for songs in your music library."),
        SettingsGroup(settings: [.updateSpotlightIndex], description: "Update Spotlight index for songs in your music library.\n\nSpotlight allows you to easily find and use the content on your iPhone that match your search sorted by the apps they belong to. You can access Spotlight by going to your home screen and swiping down from the middle of the screen.")]

    override func setupViews() {
        super.setupViews()
        topBar.title = "Search"
    }
    
    private func updateSpotlightIndex() {
        SpotlightManager.indexAllData()
    }
}

extension SearchSettingsVC: SwitchSettingCellDelegate {
    
    func switchValueChanged(isOn: Bool, cell: SwitchSettingCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let setting = settingsGroups[indexPath.section].settings[indexPath.item]
        if setting == .enableSpotlight {
            SettingsManager.spotlightIsEnabled = isOn
            if isOn {
                updateSpotlightIndex()
            } else {
                SpotlightManager.removeAllData()
            }
            for index in 0..<settingsGroups.count {
                if index == indexPath.section { continue }
                collectionView.reloadSections(IndexSet(integer: index))
            }
        }
    }
}

extension SearchSettingsVC {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return settingsGroups.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingsGroups[section].settings.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let setting = settingsGroups[indexPath.section].settings[indexPath.item]
        switch setting {
        case .enableSpotlight :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SwitchSettingCell.reuseId, for: indexPath) as! SwitchSettingCell
            cell.setupTitle(setting.rawValue)
            cell.setSwitchOn(SettingsManager.spotlightIsEnabled)
            cell.delegate = self
            return cell
        case .updateSpotlightIndex :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.reuseId, for: indexPath) as! SettingCell
            cell.setupTitle(setting.rawValue)
            cell.setupTitleColor(SettingsManager.spotlightIsEnabled ? .black : .lightGray)
            cell.scaleByTap = SettingsManager.spotlightIsEnabled
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: SettingDescriptionView.reuseId, for: indexPath) as! SettingDescriptionView
        view.setupDescription(settingsGroups[indexPath.section].description)
        return view
    }
}

extension SearchSettingsVC {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let setting = settingsGroups[indexPath.section].settings[indexPath.item]
        switch setting {
        case .enableSpotlight : break
        case .updateSpotlightIndex :
            if SettingsManager.spotlightIsEnabled {
                updateSpotlightIndex()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 32, height: 70)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let textSize = settingsGroups[section].description.textSizeForMaxWidth(view.frame.width - 2*SettingDescriptionView.textHorizontalInset, font: SettingDescriptionView.font!)
        return CGSize(width: view.frame.width, height: textSize.height + 2*SettingDescriptionView.textVerticalInset)
    }
}


