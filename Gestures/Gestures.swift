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
    private static var _handlers = [String: [Gesture: (UIGestureRecognizer) -> ()]]()
    private static var _removeHandlers = [String: [Gesture: () -> ()]]()
    fileprivate var hashString: String { hashValue.description }
    
    @objc private func _callHandler(_ sender: UIGestureRecognizer) {
        let gesture = Gesture(gesture: sender)
        UIView._handlers[hashString]?[gesture]?(sender)
        
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
    func recognize(_ gesture: Gesture, target: Any, action: Selector, setup: (UIGestureRecognizer) -> () = { _ in }) -> UIGestureRecognizer? {
        if debug {
            print("Adding handler on view \(hashString), for gesture \(gesture)")
        }
        
        guard let recognizer = gesture.gesture else {
            return nil
        }
        
        setup(recognizer)
        recognizer.addTarget(target, action: action)
        addGestureRecognizer(recognizer)
        isUserInteractionEnabled = true
        
        UIView._removeHandlers[hashString, default: [:]][gesture] = { [weak recognizer] in
            recognizer?.removeTarget(target, action: action)
        }
        
        return recognizer
    }
    
    /// Recognizes with blocks
    ///
    /// - Returns: UIGesureRecognizer that handles current gesture
    @discardableResult
    func recognize(_ gesture: Gesture, setup: (UIGestureRecognizer) -> () = { _ in }, handler: @escaping (UIGestureRecognizer) -> ()) -> UIGestureRecognizer? {
        if debug {
            print("Adding handler on view \(hashString), for gesture \(gesture)")
        }
        
        guard let recognizer = gesture.gesture else {
            return nil
        }
        
        setup(recognizer)
        recognizer.addTarget(self, action: #selector(_callHandler(_:)))
        addGestureRecognizer(recognizer)
        isUserInteractionEnabled = true
        
        UIView._handlers[hashString, default: [:]][gesture] = handler
        UIView._removeHandlers[hashString, default: [:]][gesture] = { [weak recognizer, weak self] in
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
        case tap
        case pan
        case pinch
        case longPress
        case rotation
        case swipe
        case screenEdgePan
        case none
        
        fileprivate init(gesture: UIGestureRecognizer) {
            switch gesture {
            case is UITapGestureRecognizer:
                self = .tap
            case is UIPanGestureRecognizer:
                self = .pan
            case is UIPinchGestureRecognizer:
                self = .pinch
            case is UILongPressGestureRecognizer:
                self = .longPress
            case is UIRotationGestureRecognizer:
                self = .rotation
            case is UISwipeGestureRecognizer:
                self = .swipe
            case is UIScreenEdgePanGestureRecognizer:
                self = .screenEdgePan
            default:
                self = .none
            }
        }
        
        fileprivate var gesture: UIGestureRecognizer? {
            switch self {
            case .tap:
                return UITapGestureRecognizer()
            case .pan:
                return UIPanGestureRecognizer()
            case .pinch:
                return UIPinchGestureRecognizer()
            case .longPress:
                return UILongPressGestureRecognizer()
            case .rotation:
                return UIRotationGestureRecognizer()
            case .swipe:
                return UISwipeGestureRecognizer()
            case .screenEdgePan:
                return UIScreenEdgePanGestureRecognizer()
            case .none:
                return nil
            }
        }
    }
}


