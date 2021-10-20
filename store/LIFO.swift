//
//  LIFO.swift
//  store
//

import Foundation

struct LIFO<Element> where Element: Equatable {

    private var storage = [Element]()

    var count: Int {
        storage.count
    }

    var isEmpty: Bool {
        peek() == nil
    }

    func peek() -> Element? {
        storage.last
    }

    mutating func push(_ element: Element) {
        storage.append(element)
    }

    @discardableResult
    mutating func pop() -> Element? {
        storage.popLast()
    }

}
