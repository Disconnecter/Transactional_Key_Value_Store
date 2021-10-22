//
//  store_test.swift
//  store_test
//

import XCTest
@testable import store

class store_test: XCTestCase {

    var storage: TransactionalStorage?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        storage = TransactionalStorage()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        storage = nil
    }

    func testSetGet() throws {
        storage?.set(key: "foo", value: "123")
        XCTAssertEqual(try storage?.get(key: "foo"), "123", "Not valid value")

        storage?.set(key: "foo", value: "456")
        XCTAssertEqual(try storage?.get(key: "foo"), "456", "Not valid value")
    }

    func testDelete() throws {
        storage?.set(key: "foo", value: "123")
        do {
            try storage?.delete(key: "foo")
        } catch {
            XCTFail("wrong error")
        }

        XCTAssertThrowsError(try storage?.get(key: "foo"), "wrong error") { error in
            XCTAssertEqual(error as? TransactionalStorage.TransactionalStorageError, TransactionalStorage.TransactionalStorageError.keyNotSet)
        }
    }

    func testCount() {
        storage?.set(key: "foo", value: "123")
        storage?.set(key: "bar", value: "456")
        storage?.set(key: "baz", value: "123")
        XCTAssertEqual(storage?.count(value: "123"), 2, "Not valid value")
        XCTAssertEqual(storage?.count(value: "456"), 1, "Not valid value")
    }

    func testCommitTransaction() {
        storage?.begin()
        storage?.set(key: "foo", value: "456")
        try! storage?.commit()
        XCTAssertThrowsError(try storage?.rollback(), "wrong error") { error in
            XCTAssertEqual(error as? TransactionalStorage.TransactionalStorageError, TransactionalStorage.TransactionalStorageError.noTransaction)
        }

        XCTAssertEqual(try storage?.get(key: "foo"), "456", "Not valid value")
    }

    func testRollbackTransaction() {
        storage?.set(key: "foo", value: "123")
        storage?.set(key: "bar", value: "abc")
        storage?.begin()
        storage?.set(key: "foo", value: "456")

        XCTAssertEqual(try storage?.get(key: "foo"), "456", "Not valid value")

        storage?.set(key: "bar", value: "def")
        XCTAssertEqual(try storage?.get(key: "bar"), "def", "Not valid value")

        try! storage?.rollback()

        XCTAssertEqual(try storage?.get(key: "foo"), "123", "Not valid value")
        XCTAssertEqual(try storage?.get(key: "bar"), "abc", "Not valid value")
        XCTAssertThrowsError(try storage?.commit(), "wrong error") { error in
            XCTAssertEqual(error as? TransactionalStorage.TransactionalStorageError, TransactionalStorage.TransactionalStorageError.noTransaction)
        }
    }

    func testNestedTransactions() {
        storage?.set(key: "foo", value: "123")
        storage?.begin()
        storage?.set(key: "foo", value: "456")
        storage?.begin()
        storage?.set(key: "foo", value: "789")

        XCTAssertEqual(try storage?.get(key: "foo"), "789", "Not valid value")
        try! storage?.rollback()
        XCTAssertEqual(try storage?.get(key: "foo"), "456", "Not valid value")
        try! storage?.rollback()
        XCTAssertEqual(try storage?.get(key: "foo"), "123", "Not valid value")
    }
}
