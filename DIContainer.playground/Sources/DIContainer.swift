import Foundation

public class DIContainer {

    public typealias VoidFactory<T> = () -> T
    public typealias Factory<T> = (DIContainer) -> T
    public typealias SingleArgumentFactory<T, A> = (A) -> T
    public typealias TwoArgumentsFactory<T, A, B> = (A, B) -> T
    public typealias ThreeArgumentsFactory<T, A, B, C> = (A, B, C) -> T

    private typealias AnyFactory = Factory<Any>

    public struct Configurator {

        private let container: DIContainer

        init(container: DIContainer) {
            self.container = container
        }

        public func getInstance<T>() -> T {
            return container.getInstance()
        }

        public func register<T>(_ factory: @escaping Factory<T>, as type: T.Type = T.self) {
            container.register(factory, as: type)
        }

        public func register<T, A>(_ factory: @escaping SingleArgumentFactory<T, A>, as type: T.Type = T.self) {
            let cFactory: Factory<T> = { container in factory(container.getInstance()) }
            register(cFactory, as: type)
        }

        public func register2<T, A, B>(_ factory: @escaping TwoArgumentsFactory<T, A, B>, as type: T.Type = T.self) {
            let cFactory: Factory<T> = { container in factory(container.getInstance(), container.getInstance()) }
            register(cFactory, as: type)
        }

        public func register3<T, A, B, C>(_ factory: @escaping ThreeArgumentsFactory<T, A, B, C>, as type: T.Type = T.self) {
            let cFactory: Factory<T> = { container in factory(container.getInstance(), container.getInstance(), container.getInstance()) }
            register(cFactory, as: type)
        }
    }

    private var factories = [Key: AnyFactory]()

    private var instances = [Key: Any]()

    public init(configuration: (Configurator) -> Void) {
        configuration(Configurator(container: self))
    }

    deinit {
        print("deinit")
    }

    public func getInstance<T>() -> T {
        guard T.self != Void.self else {
            return Void() as! T
        }

        if let instance = instances[Key(T.self)] as? T {
            return instance
        }

        let factory = getFactory(forType: T.self)

        let newInstance = factory(self)

        instances[Key(T.self)] = newInstance

        return newInstance
    }

    public func verify() {
        for factory in factories.values {
            _ = factory(self)
        }
    }

    private func getFactory<T>(forType: T.Type) -> Factory<T> {
        guard let factory = factories[Key(T.self)] else {
            fatalError("Type \(String(describing: T.self)) hasn't been registered in factory")
        }

        return { container in factory(container) as! T }
    }

    private func register<T>(_ factory: @escaping Factory<T>, as type: T.Type) {
        factories[Key(T.self)] = factory
    }
}

private struct Key: Hashable {

    static func ==(lhs: Key, rhs: Key) -> Bool {
        return lhs.type == rhs.type
    }

    private let type: Any.Type

    init(_ type: Any.Type) {
        self.type = type
    }

    var hashValue: Int {
        return ObjectIdentifier(type).hashValue
    }
}
