Pod::Spec.new do |s|
  s.name             = 'SwiftUIAnimationMasterclass'
  s.version          = '1.0.0'
  s.summary          = 'Beautiful animations and transitions for SwiftUI applications.'
  s.description      = <<-DESC
    SwiftUIAnimationMasterclass provides a collection of beautiful animations and
    transitions for SwiftUI. Features include spring animations, keyframe animations,
    particle effects, morphing, gesture-driven animations, and performance optimized
    animation utilities.
  DESC

  s.homepage         = 'https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhittin Camdali' => 'contact@muhittincamdali.com' }
  s.source           = { :git => 'https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.tvos.deployment_target = '15.0'
  s.watchos.deployment_target = '8.0'

  s.swift_versions = ['5.9', '5.10', '6.0']
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Foundation', 'SwiftUI'
end
