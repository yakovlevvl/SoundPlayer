//
//  MulticastDelegate.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 06.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import Foundation

class MulticastDelegate<T> {
	
    private let delegates: NSHashTable<AnyObject>

    var isEmpty: Bool {
        return delegates.count == 0
    }
    
    init(strongReferences: Bool = false) {
        delegates = strongReferences ? NSHashTable<AnyObject>() : NSHashTable<AnyObject>.weakObjects()
    }
	
	func add(_ delegate: T) {
		delegates.add(delegate as AnyObject)
	}
    
	func remove(_ delegate: T) {
		delegates.remove(delegate as AnyObject)
	}
	
	func invoke(_ invocation: (T) -> ()) {
		for delegate in delegates.allObjects {
			invocation(delegate as! T)
		}
	}

    func contains(_ delegate: T) -> Bool {
        return delegates.contains(delegate as AnyObject)
    }
}

func +=<T>(left: MulticastDelegate<T>, right: T) {
	left.add(right)
}

func -=<T>(left: MulticastDelegate<T>, right: T) {
	left.remove(right)
}

