//
//  Static.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

extension ApiConfig {
    static let apiHost = "\u{68}\u{74}\u{74}\u{70}\u{73}\u{3a}\u{2f}\u{2f}\u{72}\u{61}\u{6e}\u{64}\u{6f}\u{6d}\u{75}\u{73}\u{65}\u{72}\u{2e}\u{6d}\u{65}\u{2f}"
}

typealias TypeOfId = Int16


func print(_ item: @autoclosure () -> Any) {
    #if DEBUG
    Swift.print(item(), terminator: "\n")
    #endif
}

func print(_ item0: @autoclosure () -> Any, _ item1: @autoclosure () -> Any) {
    #if DEBUG
    Swift.print([item0(), item1()].map { "\($0)" }.joined(separator: " "), terminator: "\n")
    #endif
}
