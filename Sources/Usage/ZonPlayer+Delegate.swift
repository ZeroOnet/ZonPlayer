//
//  ZonPlayer+Delegate.swift
//  ZonPlayer
//
//  Created by 李文康 on 2023/11/6.
//

extension ZonPlayer {
    // From https://github.com/onevcat/Kingfisher/blob/277f1ab2c6664b19b4a412e32b094b201e2d5757/Sources/Utility/Delegate.swift#L71
    public final class Delegate<Input, Output> {
        public init() {}

        private var block: ((Input) -> Output?)?
        @discardableResult
        public func delegate<T: AnyObject>(on target: T, block: ((T, Input) -> Output)?) -> Self {
            self.block = { [weak target] input in
                guard let target = target else { return nil }
                return block?(target, input)
            }
            return self
        }

        public func call(_ input: Input) -> Output? { block?(input) }
        public func callAsFunction(_ input: Input) -> Output? { call(input) }
    }
}

extension ZonPlayer.Delegate where Input == Void {
    public func call() -> Output? { call(()) }
    public func callAsFunction() -> Output? { call() }
}

extension ZonPlayer.Delegate where Input == Void, Output: OptionalProtocol {
    public func call() -> Output { call(()) }
    public func callAsFunction() -> Output { call() }
}

extension ZonPlayer.Delegate where Output: OptionalProtocol {
    public func call(_ input: Input) -> Output {
        if let result = block?(input) {
            return result
        } else {
            return Output._createNil
        }
    }

    public func callAsFunction(_ input: Input) -> Output { call(input) }
}

public protocol OptionalProtocol {
    static var _createNil: Self { get }
}
extension Optional: OptionalProtocol {
    public static var _createNil: Wrapped? { nil }
}
