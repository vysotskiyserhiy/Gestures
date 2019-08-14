# Gestures

[![Version](https://img.shields.io/cocoapods/v/Gestures.svg?style=flat)](http://cocoapods.org/pods/Gestures)
[![License](https://img.shields.io/cocoapods/l/Gestures.svg?style=flat)](http://cocoapods.org/pods/Gestures)
[![Platform](https://img.shields.io/cocoapods/p/Gestures.svg?style=flat)](http://cocoapods.org/pods/Gestures)


## Add recognizers

```swift
let view = UIView()

view.recognize(.tap) { _ in
    // handle tap
}

view.recognize(.swipe(.left)) { (_) in
    // handle left swipe
}

// Or use target/selector
view.recognize(.edgeScreenPan(.left), target: self, action: #selector(handleEdgePan))

// If you need any additional setup...
view.recognize(.panSetup(minimumNumberOfTouches: 1, maximumNumberOfTouches: 4)) { (_) in
    // ...
}

```

## Installation

Gestures is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Gestures'
```

## Author

Serge Vysotsky

## License

Gestures is available under the MIT license. See the LICENSE file for more info.
