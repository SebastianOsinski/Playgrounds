public final class ExpressionContext {

    private var variables = [String: Int]()

    public init() {}

    public func setVariable(_ name: String, value: Int) {
        variables[name] = value
    }

    public func value(of variable: String) -> Int? {
        return variables[variable]
    }
}

extension ExpressionContext: ExpressibleByDictionaryLiteral {

    public convenience init(dictionaryLiteral elements: (String, Int)...) {
        self.init()
        for (key, value) in elements {
            setVariable(key, value: value)
        }
    }
}

public enum ExpressionEvaluationError: Error {
    case variableDoesNotExist
}

public indirect enum Expression {
    case literal(Int)
    case variable(String)
    case add(Expression, Expression)
    case diff(Expression, Expression)
    case multiply(Expression, Expression)
    case divide(Expression, Expression)

    public func evaluate(in context: ExpressionContext) throws -> Int {
        return try _expression().evaluate(in: context)
    }

    private func _expression() -> _Expression {
        switch self {
        case .literal(let literal):
            return _LiteralExpression(literal: literal)
        case .variable(let variable):
            return _VariableExpression(name: variable)
        case .add(let lhs, let rhs):
            return _BinaryExpression(
                lhs: lhs._expression(),
                rhs: rhs._expression(),
                operation: BinaryOperation(eval: +, symbol: "+")
            )
        case .diff(let lhs, let rhs):
            return _BinaryExpression(
                lhs: lhs._expression(),
                rhs: rhs._expression(),
                operation: BinaryOperation(eval: -, symbol: "-")
            )
        case .multiply(let lhs, let rhs):
            return _BinaryExpression(
                lhs: lhs._expression(),
                rhs: rhs._expression(),
                operation: BinaryOperation(eval: *, symbol: "*")
            )
        case .divide(let lhs, let rhs):
            return _BinaryExpression(
                lhs: lhs._expression(),
                rhs: rhs._expression(),
                operation: BinaryOperation(eval: /, symbol: "/")
            )
        }
    }
}

extension Expression: CustomStringConvertible {

    public var description: String {
        return _expression().description
    }
}

extension Expression: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self = .literal(value)
    }
}

extension Expression: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .variable(value)
    }
}

extension Expression {

    public static func +(lhs: Expression, rhs: Expression) -> Expression {
        return .add(lhs, rhs)
    }

    public static func -(lhs: Expression, rhs: Expression) -> Expression {
        return .diff(lhs, rhs)
    }

    public static func *(lhs: Expression, rhs: Expression) -> Expression {
        return .multiply(lhs, rhs)
    }

    public static func /(lhs: Expression, rhs: Expression) -> Expression {
        return .divide(lhs, rhs)
    }
}

