//
//  Protected.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

// From https://github.com/Alamofire/Alamofire/blob/3dc6a42c7727c49bf26508e29b0a0b35f9c7e1ad/Source/Protected.swift#L84
@propertyWrapper
final class Protected<T> {
    private let lock = NSLock()
    private var value: T
    init(value: T) {
        self.value = value
    }

    var wrappedValue: T {
        get { lock.around { value } }
        set { lock.around { value = newValue } }
    }

    var projectedValue: Protected<T> { self }

    init(wrappedValue: T) {
        value = wrappedValue
    }

    func read<U>(_ closure: (T) -> U) -> U {
        lock.around { closure(value) }
    }

    func write<U>(_ closure: (inout T) -> U) -> U {
        lock.around { closure(&value) }
    }
}

protocol Lockable {
    func lock()
    func unlock()
}

extension Lockable {
    func around<T>(_ closure: () -> T) -> T {
        lock(); defer { unlock() }
        return closure()
    }
}

extension NSLock: Lockable {}
