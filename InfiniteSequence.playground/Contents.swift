import Foundation

struct InfiniteRecursiveSequence<Element>: LazySequenceProtocol {

    typealias NextElement = (Element) -> Element

    private let firstElement: Element
    private let nextElement: NextElement

    init(firstElement: Element, nextElement: @escaping NextElement) {
        self.firstElement = firstElement
        self.nextElement = nextElement
    }

    struct Iterator: IteratorProtocol {

        private var currentElement: Element
        private let nextElement: NextElement

        init(firstElement: Element, nextElement: @escaping NextElement) {
            self.currentElement = firstElement
            self.nextElement = nextElement
        }

        mutating func next() -> Element? {
            defer { currentElement = nextElement(currentElement) }
            return currentElement
        }
    }

    func makeIterator() -> Iterator {
        return Iterator(firstElement: firstElement, nextElement: nextElement)
    }
}

let sequence = InfiniteRecursiveSequence(firstElement: 10) { 2 * $0 }

for element in sequence.prefix(10) {
    print(element)
}

