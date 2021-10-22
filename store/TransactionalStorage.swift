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

    private var stack: LIFO<[AnyHashable: AnyHashable]>

    init() {
        self.stack = LIFO()
        self.begin()
    }

    /**
     `SET` store the value for key
     - Parameter key: uniq key
     - Parameter value: value for store
     */
    func set(key: AnyHashable, value: AnyHashable) {
        var set = stack.pop() ?? [AnyHashable: AnyHashable]()
        set[key] = value
        stack.push(set)
    }

    /**
     `GET`
     - Parameter key:
     - Returns: the current value for key or error
     */
    @discardableResult
    func get(key: AnyHashable) throws -> AnyHashable {
        guard let set = stack.peek(), let value = set[key]
        else {
            throw TransactionalStorageError.keyNotSet
        }
        return value
    }

    /**
     `DELETE`
     - Parameter key: remove the entry for key
     */
    func delete(key: AnyHashable) throws {
        guard var set = stack.pop(),
              var _ = set.removeValue(forKey: key)
        else {
            throw TransactionalStorageError.keyNotSet
        }
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
        return set.values.filter({ $0 == value}).count
    }

    /**
    `BEGIN`
     start a new transaction
    */
    func begin() {
        stack.push([AnyHashable: AnyHashable]())
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

        last.forEach { pair in
            set(
                key: pair.key,
                value: pair.value
            )
        }

    }

    /**
    `ROLLBACK`
     revert to state prior to `BEGIN` call
    */
    func rollback() throws {
        guard stack.count > 1 else {
            throw TransactionalStorageError.noTransaction
        }
        stack.pop()
    }

}
