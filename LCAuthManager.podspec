Pod::Spec.new do |s|
  s.name         = "LCAuthManager"
  s.version      = "1.0.0"
  s.summary      = "A comprehensive, efficient and easy-to-use rights verification library, including Gesture Password, Touch ID and Face ID."
  s.description  = <<-DESC
                   LCAuthManager has the following advantages:
                   1. Configurable, providing configuration for gesture password pages and features, such as password length, maximum number of trial and error, and auxiliary operations.
                   2. Can be combined to combine gesture password and biometric verification, and be customized by the developer.
                   3. Provide a large number of external interfaces, provide external interfaces for credential storage, and developers can access their own credential storage methods.
                   4. The project provides a common demo that can help developers integrate quickly.
                   DESC
  s.homepage     = "https://github.com/LennonChin/LCAuthManager"
  s.license      = "MIT"
  s.author             = { "LennonChin" => "i@coderap.com" }
  s.social_media_url   = "https://blog.coderap.com/"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/LennonChin/LCAuthManager.git", :tag => s.version }
  s.source_files = "LCAuthManager/LCAuthManager/**/*.{h,m}"
  s.resource  = "LCAuthManager/LCAuthManager/**/*.{xib}", "LCAuthManager/LCAuthManager/Resources/LCAuthManager.bundle"
  s.requires_arc = true
end
