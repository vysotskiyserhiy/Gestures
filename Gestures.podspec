Pod::Spec.new do |s|
  s.name             = 'Gestures'
  s.version          = '0.0.1'
  s.summary          = 'UIView Gestures'
  s.homepage         = 'https://github.com/vysotskiyserhiy/Gestures'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Serge Vysotsky' => 'vysotskiyserhiy@gmail.com' }
  s.source           = { :git => 'https://github.com/vysotskiyserhiy/Gestures.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.swift_versions = '5.1'
  s.source_files = 'Gestures/Gestures.swift'
  s.frameworks = 'UIKit'
end
