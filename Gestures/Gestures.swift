//
//  Gestures.swift
//  Gestures
//
//  Created by Serhiy Vysotskiy on 27.06.2019.
//  Copyright © 2019 Serhiy Vysotskiy. All rights reserved.
//

import UIKit.UIView

let debug = false

// MARK: - Gestures
extension UIView {
    private static var _handlers = [String: [String: (UIGestureRecognizer) -> ()]]()
    private static var _removeHandlers = [String: [String: () -> ()]]()
    fileprivate var hashString: String { hashValue.description }
    
    @objc private func _callHandler(_ sender: UIGestureRecognizer) {
        let gesture = Gesture(gesture: sender)
        UIView._handlers[hashString]?[gesture.key]?(sender)
        
        if debug {
            print("Calling handler on view \(hashString), for gesture \(gesture)")
        }
    }
    
    /// Removes all handlers from view
    public func removeRecognizers() {
        if debug {
            print("Removing handlers on view \(hashString)")
        }
        
        UIView._removeHandlers.removeValue(forKey: hashString)?.values.forEach { $0() }
        UIView._handlers.removeValue(forKey: hashString)
    }
}


// MARK: - Adding recognizers
public extension UIView {
    /// Recognizes with target/selector
    ///
    /// - Returns: UIGesureRecognizer that handles current gesture
    @discardableResult
    func recognize(_ gesture: Gesture, target: Any, action: Selector) -> UIGestureRecognizer? {
        if debug {
            print("Adding handler on view \(hashString), for gesture \(gesture)")
        }
        
        guard let recognizer = gesture.gesture else {
            return nil
        }
        
        recognizer.addTarget(target, action: action)
        addGestureRecognizer(recognizer)
        isUserInteractionEnabled = true
        
        UIView._removeHandlers[hashString, default: [:]][gesture.key] = { [weak recognizer] in
            recognizer?.removeTarget(target, action: action)
        }
        
        return recognizer
    }
    
    /// Recognizes with blocks
    ///
    /// - Returns: UIGesureRecognizer that handles current gesture
    @discardableResult
    func recognize(_ gesture: Gesture, handler: @escaping (UIGestureRecognizer) -> ()) -> UIGestureRecognizer? {
        if debug {
            print("Adding handler on view \(hashString), for gesture \(gesture)")
        }
        
        guard let recognizer = gesture.gesture else {
            return nil
        }
        
        recognizer.addTarget(self, action: #selector(_callHandler(_:)))
        addGestureRecognizer(recognizer)
        isUserInteractionEnabled = true
        
        UIView._handlers[hashString, default: [:]][gesture.key] = handler
        UIView._removeHandlers[hashString, default: [:]][gesture.key] = { [weak recognizer, weak self] in
            if debug {
                print("Removing handler on view \(self?.hashString ?? "nil"), for gesture \(gesture)")
            }
            
            recognizer?.removeTarget(self, action: #selector(UIView._callHandler(_:)))
        }
        
        return recognizer
    }
}

// MARK: - Gesture
extension UIView {
    public enum Gesture {
        case tap(numberOfTapsRequired: Int = 0, numberOfTouchesRequired: Int = 1)
        case pan(minimumNumberOfTouches: Int = 1, maximumNumberOfTouches: Int = .max)
        case pinch(scale: CGFloat = 1)
        case longPress(minimumPressDuration: TimeInterval = 0.5, allowableMovement: CGFloat = 10, numberOfTapsRequired: Int = 0, numberOfTouchesRequired: Int = 1)
        case rotation
        case swipe(UISwipeGestureRecognizer.Direction)
        case screenEdgePan(UIRectEdge)
        case none
        
        var key: String {
            String(describing: self)
        }
        
        fileprivate init(gesture: UIGestureRecognizer) {
            switch gesture {
            case is UITapGestureRecognizer:
                let tap = gesture as! UITapGestureRecognizer
                self = .tap(numberOfTapsRequired: tap.numberOfTapsRequired, numberOfTouchesRequired: tap.numberOfTouchesRequired)
            case is UIPanGestureRecognizer:
                let pan = gesture as! UIPanGestureRecognizer
                self = .pan(minimumNumberOfTouches: pan.minimumNumberOfTouches, maximumNumberOfTouches: pan.maximumNumberOfTouches)
            case is UIPinchGestureRecognizer:
                let pinch = gesture as! UIPinchGestureRecognizer
                self = .pinch(scale: pinch.scale)
            case is UILongPressGestureRecognizer:
                let longPress = gesture as! UILongPressGestureRecognizer
                self = .longPress(minimumPressDuration: longPress.minimumPressDuration, allowableMovement: longPress.allowableMovement, numberOfTapsRequired: longPress.numberOfTapsRequired, numberOfTouchesRequired: longPress.numberOfTouchesRequired)
            case is UIRotationGestureRecognizer:
                self = .rotation
            case is UISwipeGestureRecognizer:
                let swipe = gesture as! UISwipeGestureRecognizer
                self = .swipe(swipe.direction)
            case is UIScreenEdgePanGestureRecognizer:
                let screenEdgePan = gesture as! UIScreenEdgePanGestureRecognizer
                self = .screenEdgePan(screenEdgePan.edges)
            default:
                self = .none
            }
        }
        
        fileprivate var gesture: UIGestureRecognizer? {
            switch self {
            case let .tap(numberOfTapsRequired, numberOfTouchesRequired):
                let tap = UITapGestureRecognizer()
                tap.numberOfTapsRequired = numberOfTapsRequired
                tap.numberOfTouchesRequired = numberOfTouchesRequired
                return UITapGestureRecognizer()
            case let .pan(minimumNumberOfTouches, maximumNumberOfTouches):
                let pan = UIPanGestureRecognizer()
                pan.minimumNumberOfTouches = minimumNumberOfTouches
                pan.maximumNumberOfTouches = maximumNumberOfTouches
                return pan
            case let .pinch(scale):
                let pinch = UIPinchGestureRecognizer()
                pinch.scale = scale
                return pinch
            case let .longPress(minimumPressDuration, allowableMovement, numberOfTapsRequired, numberOfTouchesRequired):
                let press = UILongPressGestureRecognizer()
                press.minimumPressDuration = minimumPressDuration
                press.allowableMovement = allowableMovement
                press.numberOfTapsRequired = numberOfTapsRequired
                press.numberOfTouchesRequired = numberOfTouchesRequired
                return press
            case .rotation:
                return UIRotationGestureRecognizer()
            case let .swipe(direction):
                let swipe = UISwipeGestureRecognizer()
                swipe.direction = direction
                return swipe
            case let .screenEdgePan(edges):
                let pan = UIScreenEdgePanGestureRecognizer()
                pan.edges = edges
                return pan
            case .none:
                return nil
            }
        }
    }
}


