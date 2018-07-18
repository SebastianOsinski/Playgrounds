import Foundation
import PlaygroundSupport

protocol Lock: class {
    func read<T>(_ criticalSection: () -> (T)) -> T
    func write(_ criticalSection: () -> ())
}

final class ReadersWriterLock: Lock {
    private var lock: pthread_rwlock_t

    init() {
        lock = pthread_rwlock_t()
        pthread_rwlock_init(&lock, nil)
    }

    func read<T>(_ criticalSection: () -> (T)) -> T {
        pthread_rwlock_rdlock(&lock)
        let value = criticalSection()
        pthread_rwlock_unlock(&lock)

        return value
    }

    func write(_ criticalSection: () -> ()) {
        pthread_rwlock_wrlock(&lock)
        criticalSection()
        pthread_rwlock_unlock(&lock)
    }
}

final class Atomic<T> {
    var value: T {
        get {
            return lock.read {
                return _value
            }
        }
        set {
            lock.write {
                _value = newValue
            }
        }
    }

    private var _value: T
    private let lock: Lock

    init(_ value: T, lock: Lock = ReadersWriterLock()) {
        _value = value
        self.lock = lock
    }
}

final class AtomicArray<Element> {
    private var elements: [Element]
    private let lock: Lock

    init(lock: Lock = ReadersWriterLock()) {
        elements = []
        self.lock = lock
    }

    func append(_ element: Element) {
        lock.write {
            elements.append(element)
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

let queue1 = DispatchQueue(label: "1")
let queue2 = DispatchQueue(label: "2")
let queue3 = DispatchQueue(label: "2")
let queue4 = DispatchQueue(label: "2")

var array = Atomic<[Int]>([])

for i in 1...100000 {
    queue1.async {
        array.value.append(i)
    }
    queue2.async {
        array.value.append(i)
    }
    queue3.async {
        array.value.append(i)
    }
    queue4.async {
        array.value.append(i)
    }
}

