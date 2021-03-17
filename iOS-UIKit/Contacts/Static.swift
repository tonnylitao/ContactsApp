//
//  Static.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

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

/*
 https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-t-o-d-o.html
 */
func TODO(_ message: String = "") {
    #if DEBUG
    fatalError(message)
    #endif
}
