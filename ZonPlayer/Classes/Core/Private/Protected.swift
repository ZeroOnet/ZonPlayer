//
//  Protected.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/3.
//

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

private protocol _Lockable {
    func lock()
    func unlock()
}

extension _Lockable {
    func around<T>(_ closure: () -> T) -> T {
        lock(); defer { unlock() }
        return closure()
    }
}

extension NSLock: _Lockable {}
