//
//  SettingsGroup.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 18.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

struct SettingsGroup<E: RawRepresentable> where E.RawValue == String {
    
    let settings: [E]
    
    let description: String
}
