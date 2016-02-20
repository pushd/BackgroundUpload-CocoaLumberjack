#
# Be sure to run `pod lib lint BackgroundUpload-CocoaLumberjack.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BackgroundUpload-CocoaLumberjack"
  s.version          = "0.3.5"
  s.summary          = "Remote logging via NSURLSession transfer to upload NSLog logger logs to an HTTP server such as loggly."
#  s.description      = <<-DESC
#                      A LogFileManager that uses NSURLSession background transfer to upload files when they roll.
#                       DESC
  s.homepage         = "https://github.com/pushd/BackgroundUpload-CocoaLumberjack"
  s.license          = 'MIT'
  s.author           = { "Eric Jensen" => "ej@pushd.com" }
  s.source           = { :git => "https://github.com/pushd/BackgroundUpload-CocoaLumberjack.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ej'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BackgroundUpload-CocoaLumberjack' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'CocoaLumberjack'
end
