//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class FirstViewController: UIViewController {

    private let circle = UIView()
    private var transition: FirstSecondTransition?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(circle)
        circle.backgroundColor = .red
        circle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(circlePanned)))
        circle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(circleTapped)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        circle.frame = CGRect(center: view.center, size: CGSize(width: 100, height: 100))
        circle.layer.cornerRadius = 50
    }

    @objc private func circlePanned(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)

        circle.frame.origin += translation

        recognizer.setTranslation(.zero, in: view)
    }

    @objc private func circleTapped() {
        let secondViewController = SecondViewController()
        secondViewController.transitioningDelegate = self
        present(secondViewController, animated: true, completion: nil)
    }
}

extension FirstViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition = FirstSecondTransition(originFrame: circle.frame)
        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition?.presenting = false
        return transition
    }
}

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
    }

    @objc private func viewTapped() {
        dismiss(animated: true, completion: nil)
    }
}


class FirstSecondTransition: NSObject, UIViewControllerAnimatedTransitioning {

    private let originFrame: CGRect
    private let duration: TimeInterval = 1.0

    var presenting = true

    init(originFrame: CGRect) {
        self.originFrame = originFrame
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.completeTransition(true)
    }
}

PlaygroundPage.current.liveView = FirstViewController()
