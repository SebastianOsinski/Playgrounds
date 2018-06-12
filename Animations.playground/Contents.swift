//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

final class KeyframeAnimator {

    private struct AnimationsData {
        let animations: Animations
        let relativeTimeStart: Double
        let relativeDuration: Double
    }

    typealias Animations = () -> Void

    private var animationsDataList = [AnimationsData]()

    func addKeyframe(withRelativeStartTime relativeStartTime: Double, relativeDuration: Double, animations: @escaping Animations) -> KeyframeAnimator {

        let data = AnimationsData(
            animations: animations,
            relativeTimeStart: relativeStartTime,
            relativeDuration: relativeDuration
        )

        animationsDataList.append(data)

        return self
    }

    func animate(withDuration duration: TimeInterval, delay: TimeInterval = 0.0, options: UIViewKeyframeAnimationOptions = [], completion: ((Bool) -> Void)? = nil) {
        UIView.animateKeyframes(
            withDuration: duration,
            delay: delay,
            options: options,
            animations: { [animationsDataList] in
                for data in animationsDataList {
                    UIView.addKeyframe(
                        withRelativeStartTime: data.relativeTimeStart,
                        relativeDuration: data.relativeDuration,
                        animations: data.animations
                    )
                }
            },
            completion: completion
        )

        animationsDataList = []
    }
}

extension CGAffineTransform {

    static func +=(lhs: inout CGAffineTransform, rhs: CGAffineTransform) {
        lhs = lhs.concatenating(rhs)
    }
}

extension UIView {

    static var keyframeAnimator: KeyframeAnimator {
        return KeyframeAnimator()
    }
}

extension CGRect {

    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2
        )

        self.init(
            origin: origin,
            size: size
        )
    }

    var center: CGPoint {
        return CGPoint(
            x: origin.x + width / 2,
            y: origin.y + height / 2
        )
    }

    func multiplyingDimensions(_ multiplier: CGFloat) -> CGRect {
        let newSize = CGSize(width: width * multiplier, height: height * multiplier)
        return CGRect(center: center, size: newSize)
    }
}

class AnimationViewController : UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        let initSize = CGSize(width: 300, height: 300)
//        let initRect = CGRect(center: view.center, size: initSize)
//
//        let numberOfCircles = 30
//
//        for i in 1...numberOfCircles {
//            let multiplier = CGFloat(i) / CGFloat(numberOfCircles)
//            let rect = initRect.multiplyingDimensions(multiplier)
//
//            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: rect.size))
//            let circleLayer = CAShapeLayer()
//
//            circleLayer.path = path.cgPath
//            circleLayer.frame = rect
//
//            circleLayer.fillColor = nil
//            circleLayer.strokeColor = UIColor.black.cgColor
//            view.layer.addSublayer(circleLayer)
//
//            let smallestCircleMultiplier = 1 / CGFloat(numberOfCircles)
//
//            let animation = CABasicAnimation(keyPath: "transform.scale")
//            animation.duration = 2
//            animation.autoreverses = true
//
//            animation.fromValue = 1 / CGFloat(i)
//            animation.toValue = 1
//            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//
//            animation.repeatCount = Float.greatestFiniteMagnitude
//            circleLayer.add(animation, forKey: "animation")
//        }
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let circle = UIView(frame: CGRect(center: view.center, size: CGSize(width: 100, height: 100)))
        view.addSubview(circle)

        circle.backgroundColor = .red

        UIView
            .keyframeAnimator
            .addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                circle.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            }
            .addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
                circle.transform += CGAffineTransform(translationX: 50, y: 50)
            }
            .addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.2) {
                circle.transform += CGAffineTransform(rotationAngle: .pi / 2)
            }
            .addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.2) {
                circle.transform += CGAffineTransform(rotationAngle: -.pi / 2)
            }
            .addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                circle.transform = .identity
            }
            .addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
                circle.backgroundColor = .yellow
            }
            .addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                circle.backgroundColor = .red
            }
            .addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4) {
                circle.layer.cornerRadius = circle.frame.width / 2
            }
            .addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                circle.layer.cornerRadius = 0
            }
            .animate(withDuration: 5.0, options: [.calculationModePaced])

    }
}
// Present the view controller in the Live View window
let vc = AnimationViewController()
PlaygroundPage.current.liveView = vc

