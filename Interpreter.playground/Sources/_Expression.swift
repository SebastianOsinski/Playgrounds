
protocol _Expression: CustomStringConvertible {
    func evaluate(in context: ExpressionContext) throws -> Int
}

struct _LiteralExpression: _Expression {

    private let literal: Int

    var description: String {
        return "\(literal)"
    }

    init(literal: Int) {
        self.literal = literal
    }

    func evaluate(in context: ExpressionContext) throws -> Int {
        return literal
    }
}

struct _VariableExpression: _Expression {

    private let name: String

    var description: String {
        return name
    }

    init(name: String) {
        self.name = name
    }

    func evaluate(in context: ExpressionContext) throws -> Int {
        if let value = context.value(of: name) {
            return value
        } else {
            throw ExpressionEvaluationError.variableDoesNotExist
        }
    }
}

struct BinaryOperation {
    typealias Operation = (Int, Int) -> Int
    let eval: Operation
    let symbol: String
}

struct _BinaryExpression: _Expression {

    private let lhs: _Expression
    private let rhs: _Expression
    private let operation: BinaryOperation

    var description: String {
        return "(\(lhs) \(operation.symbol) \(rhs))"
    }

    init(lhs: _Expression, rhs: _Expression, operation: BinaryOperation) {
        self.lhs = lhs
        self.rhs = rhs
        self.operation = operation
    }

    func evaluate(in context: ExpressionContext) throws -> Int {
        return operation.eval(try lhs.evaluate(in: context), try rhs.evaluate(in: context))
    }
}
