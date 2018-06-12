import CoreGraphics

public extension CGAffineTransform {

   public static func +=(lhs: inout CGAffineTransform, rhs: CGAffineTransform) {
        lhs = lhs.concatenating(rhs)
    }
}

public extension CGPoint {

    public static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
}

public extension CGRect {

    public var center: CGPoint {
        return CGPoint(
            x: origin.x + width / 2,
            y: origin.y + height / 2
        )
    }

    public init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2
        )

        self.init(
            origin: origin,
            size: size
        )
    }

    public func multiplyingDimensions(_ multiplier: CGFloat) -> CGRect {
        let newSize = CGSize(width: width * multiplier, height: height * multiplier)
        return CGRect(center: center, size: newSize)
    }
}
