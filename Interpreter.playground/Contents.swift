import Foundation

let context: ExpressionContext = [
    "x": 4,
    "y": 2
]

let expression0: Expression = .divide(
    .add(
        .multiply(
            .variable("x"),
            .variable("y")
        ),
        .literal(10)
    ),
    .literal(2)
)
let expression1: Expression = ("x" * "y" + 10) / 2

try! expression0.evaluate(in: context)
try! expression1.evaluate(in: context)
