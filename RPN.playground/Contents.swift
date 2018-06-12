final class RPNCalculator {

    enum Error: Swift.Error {
        case incorrectSymbol
        case malformedExpression
    }

    private enum Symbol {

        enum Operator: String {
            case add = "+"
            case diff = "-"
            case mult = "*"
            case div = "/"
        }

        case number(Double)
        case `operator`(Operator)

        init?(string: String) {
            if let number = Double(string) {
                self = .number(number)
            } else if let `operator` = Operator(rawValue: string) {
                self = .`operator`(`operator`)
            } else {
                return nil
            }
        }
    }

    static func calculate(expression: String) throws -> Double {
        let symbolStrings = expression.split(separator: " ").map(String.init)

        var stack = [Double]()

        for symbolString in symbolStrings {
            guard let symbol = Symbol(string: symbolString) else {
                throw Error.incorrectSymbol
            }

            switch symbol {
            case .number(let number):
                stack.append(number)
            case .operator(let `operator`):
                guard
                    let a = stack.popLast(),
                    let b = stack.popLast()
                else {
                    throw Error.malformedExpression
                }

                stack.append(evaluate(operator: `operator`, lhs: b, rhs: a))
            }
        }

        guard
            let result = stack.popLast(),
            stack.isEmpty
        else {
            throw Error.malformedExpression
        }

        return result
    }

    private static func evaluate(`operator`: Symbol.Operator, lhs: Double, rhs: Double) -> Double {
        switch `operator` {
        case .add:
            return lhs + rhs
        case .diff:
            return lhs - rhs
        case .mult:
            return lhs * rhs
        case .div:
            return lhs / rhs
        }
    }
}

let expression = "12 2 3 4 * 10 5 / + * +"

print(try! RPNCalculator.calculate(expression: expression))
