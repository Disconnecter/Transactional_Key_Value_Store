//
//  main.swift
//  store
//

import Foundation

print("Hello, World!")
print ("SET <key> <value> store the value for key")
print ("GET <key>         return the current value for key")
print ("DELETE <key>      remove the entry for key")
print ("COUNT <value>     return the number of keys that have the given value")
print ("BEGIN             start a new transaction")
print ("COMMIT            complete the current transaction")
print ("ROLLBACK          revert to state prior to BEGIN call")

let storage = TransactionalStorage()

while let command = readLine(), command != "EXIT" {

    let parsed = command.components(separatedBy: .whitespaces)

    do {
        switch parsed.first {
        case "SET":
            if let key: String = parsed[safe: 1], let value: String = parsed[safe: 2] {
                storage.set(key: key, value: value)
            } else {
                print ("SET <key> <value> store the value for key")
            }
        case "GET":
            if let key: String = parsed[safe: 1] {
                print(try storage.get(key: key))
            } else {
                print ("GET <key> return the current value for key")
            }

        case "DELETE":
            if let key: String = parsed[safe: 1] {
                try storage.delete(key: key)
            } else {
                print ("DELETE <key> remove the entry for key")
            }
        case "COUNT":
            if let value: String = parsed[safe: 1] {
                print(storage.count(value: value))
            } else {
                print ("COUNT <value> return the number of keys that have the given value")
            }
        case "BEGIN":
            storage.begin()
        case "COMMIT":
            print(try storage.commit())
        case "ROLLBACK":
            print(try storage.rollback())
        default :
            print("not supported")
        }
    } catch TransactionalStorage.TransactionalStorageError.noTransaction {
        print("no transaction")
    } catch TransactionalStorage.TransactionalStorageError.keyNotSet {
        print("key not set")
    } catch {
        print("Unexpected error: \(error).")
    }

}
