//
//  UserSwipeOverlay.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 01/11/2021.
//

import Foundation
import Shuffle_iOS
import UIKit

class UserSwipeOverlay: UIView {
    
    init(direction: SwipeDirection) {
        super.init(frame :.zero)
        switch direction {
        case .left:
            leftOverlay()
        case .right:
            rightOverlay()
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func leftOverlay() {
        let left = SampleOverlayLabelView(withTitle: "REJECT", color: .red, rotation: CGFloat.pi/10)
        addSubview(left)
        left.anchor(top: topAnchor, right: rightAnchor, paddingTop: 30, paddingRight: 14)
    }
    
    private func rightOverlay(){
        let right = SampleOverlayLabelView(withTitle: "MATCH", color: .green, rotation: -CGFloat.pi/10)
        addSubview(right)
        right.anchor(top: topAnchor, left: leftAnchor, paddingTop: 26, paddingRight: 14)
    }
}

private class SampleOverlayLabelView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    init(withTitle title: String, color: UIColor, rotation: CGFloat) {
        super.init(frame:  CGRect.zero)
        layer.borderColor = color.cgColor
        layer.borderWidth = 4
        layer.cornerRadius = 4
        transform = CGAffineTransform(rotationAngle: rotation)
        
        addSubview(titleLabel)
        titleLabel.textColor = color
        titleLabel.attributedText = NSAttributedString(string: title, attributes: NSAttributedString.Key.overlayAttributes)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}

extension NSAttributedString.Key {
    
    static var overlayAttributes: [NSAttributedString.Key: Any] = [
        // swiftlint:disable:next force_unwrapping
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 42)!,
        NSAttributedString.Key.kern: 5.0
    ]
}
