indirect enum List<T> {
    case cons(T, List<T>)
    case `nil`

    var head: T? {
        switch self {
        case .cons(let head, _):
            return head
        case .nil:
            return nil
        }
    }

    var tail: List<T>? {
        switch self {
        case .cons(_, let tail):
            return tail
        case .nil:
            return nil
        }
    }
}

struct ListIterator<T>: IteratorProtocol {

    private var list: List<T>

    init(list: List<T>) {
        self.list = list
    }

    mutating func next() -> T? {
        switch list {
        case .cons(let head, let tail):
            list = tail
            return head
        case .nil:
            return nil
        }
    }
}

extension List: Sequence {

    typealias Iterator = ListIterator<T>

    func makeIterator() -> Iterator {
        return ListIterator<T>(list: self)
    }
}

extension List: ExpressibleByArrayLiteral {

    init(arrayLiteral elements: T...) {
        var tail: List<T> = .nil
        for element in elements.reversed() {
            tail = .cons(element, tail)
        }

        self = tail
    }
}

extension List: CustomStringConvertible {

    var description: String {
        switch self {
        case .cons(let head, let tail):
            return "\(head) -> " + tail.description
        case .nil:
            return "nil"
        }
    }
}

let list: List<Int> = .cons(1, .cons(2, .cons(3, .nil)))
let list2: List<Int> = [1, 2, 3]

for element in list {
    print(element)
}

