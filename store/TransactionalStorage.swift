//
//  TransactionalStorage.swift
//  store
//

import Foundation

final class TransactionalStorage {

    enum TransactionalStorageError: Error {
        case keyNotSet
        case noTransaction
    }

    private struct StoreValue: Hashable {

        let key: AnyHashable
        var value: AnyHashable

        func hash(into hasher: inout Hasher) {
            hasher.combine(key)
        }
    }

    private var stack: LIFO<Set<StoreValue>>

    init() {
        self.stack = LIFO()
        self.stack.push(Set<StoreValue>())
    }

    /**
     `SET` store the value for key
     - Parameter key: uniq key
     - Parameter value: value for store
     */
    func set(key: AnyHashable, value: AnyHashable) {
        var set = stack.pop() ?? Set<StoreValue>()
        if let element = set.first(where: { $0.key == key}) {
            set.remove(element)
        }
        set.insert(StoreValue(key: key, value: value))
        stack.push(set)
    }

    /**
     `GET`
     - Parameter key:
     - Returns: the current value for key or error
     */
    @discardableResult
    func get(key: AnyHashable) throws -> AnyHashable {
        guard let set = stack.peek(),
              let element = set.first(where: { $0.key == key} )
        else {
            throw TransactionalStorageError.keyNotSet
        }
        return element.value
    }

    /**
     `DELETE`
     - Parameter key: remove the entry for key
     */
    func delete(key: AnyHashable) throws {
        guard var set = stack.pop(),
              let element = set.first(where: { $0.key == key })
        else {
            throw TransactionalStorageError.keyNotSet
        }

        set.remove(element)
        stack.push(set)
    }

    /**
    `COUNT`
    - Parameter value:
    - Returns: the number of keys that have the given value
    */
    func count(value: AnyHashable) -> Int {
        guard let set = stack.peek()
        else {
            return 0
        }
        return set.filter({ $0.value == value}).count
    }


    /**
    `BEGIN`
     start a new transaction
    */
    func begin() {
        stack.push(Set<StoreValue>())
    }


    /**
    `COMMIT`
     complete the current transaction
    */
    func commit() throws {
        guard let last = stack.pop()
        else {
            throw TransactionalStorageError.noTransaction
        }

        last.forEach { element in
            set(
                key: element.key,
                value: element.value
            )
        }

    }

    /**
    `ROLLBACK`
     revert to state prior to `BEGIN` call
    */
    func rollback() throws {
        if stack.count > 1 {
            stack.pop()
        } else {
            throw TransactionalStorageError.noTransaction
        }
    }

}
