//
//  UserSwipeFooterView.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 01/11/2021.
//

import Foundation
import UIKit
class UserSwipeFooterView: UIView {
    private var label = UILabel()
    private var gradientLayer: CAGradientLayer?
    
    init(withTitle title: String?, subTitle: String?){
        super.init(frame: .zero)
        backgroundColor = .clear
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 10
        clipsToBounds = true
        isOpaque = false
        initialize(title: title, subtitle: subTitle)
        
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func initialize(title: String?, subtitle: String?) {
        let atributedText = NSMutableAttributedString(string: (title ?? "") + "\n", attributes: NSAttributedString.Key.titleAttributes)
        if let subtitle = subtitle, subtitle != "" {
            atributedText.append(NSMutableAttributedString(string: subtitle, attributes:  NSAttributedString.Key.subtitleAttributes))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            paragraphStyle.lineBreakMode = .byTruncatingTail
            atributedText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: atributedText.length))
            label.numberOfLines = 3
        }
        label.attributedText = atributedText
        addSubview(label)
    }
    
    override func layoutSubviews() {
        let padding: CGFloat = 20
        label.frame = CGRect(x: padding, y: bounds.height - label.intrinsicContentSize.height - padding, width: bounds.width, height: label.intrinsicContentSize.height)
    }
}

extension NSAttributedString.Key {

  static var shadowAttribute: NSShadow = {
    let shadow = NSShadow()
    shadow.shadowOffset = CGSize(width: 0, height: 1)
    shadow.shadowBlurRadius = 2
    shadow.shadowColor = UIColor.black.withAlphaComponent(0.3)
    return shadow
  }()

  static var titleAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font: UIFont(name: "ArialRoundedMTBold", size: 20)!,
    NSAttributedString.Key.foregroundColor: UIColor.white,
    NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
  ]

  static var subtitleAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font: UIFont(name: "Arial", size: 10)!,
    NSAttributedString.Key.foregroundColor: UIColor.white,
    NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
  ]
}
