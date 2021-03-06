#
# Be sure to run `pod lib lint XAssets.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ReactiveArray"
  s.version          = "0.7.2"
  s.summary          = "Reactive array for ReactiveCocoa."
  s.description      = <<-DESC
                       An array class implemented in Swift that can be observed using ReactiveCocoa's Signals.
                       DESC
  s.homepage         = "https://github.com/Hxucaa/ReactiveArray"
  s.license          = 'MIT'
  s.author           = { "Lance Zhu" => "lancezhu77@gmail.com" }
  s.source           = { :git => "https://github.com/Hxucaa/ReactiveArray.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'ReactiveArray/**/*'
  s.exclude_files = 'ReactiveArray/Info.plist'  

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'ReactiveCocoa', '~> 4.0.0'
end

