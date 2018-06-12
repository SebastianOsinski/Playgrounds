//: Playground - noun: a place where people can play

import UIKit




func icon(withExtension extension: String) -> UIImage {
    let template = UIImage(named: "icon")!
    let font = UIFont.systemFont(ofSize: 40, weight: .bold)

    UIGraphicsBeginImageContext(template.size)
    defer {
        UIGraphicsEndImageContext()
    }

    // Draw
    template.draw(in: CGRect(origin: .zero, size: template.size))

    let rect = CGRect(x: 79, y: 125, width: 121, height: 42)
    UIColor.red.setFill()

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    paragraphStyle.minimumLineHeight = 42
    paragraphStyle.maximumLineHeight = 42

    (`extension` as NSString).draw(
        in: rect, withAttributes: [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
    )

    let image = UIGraphicsGetImageFromCurrentImageContext()!

    return image
}


let mkvIcon = icon(withExtension: "mkv")

