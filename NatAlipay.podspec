Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "NatAlipay"
  s.version      = "0.0.1"
  s.summary      = "Nat.js Module: Alipay."
  s.homepage     = "http://natjs.com"
  s.license      = "MIT"
  s.author       = { "nat" => "hi@natjs.com" }

  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/natjs/nat-pay-alipay.git", :tag => s.version }

  s.source_files  = "ios/Classes/*.{h,m}"

  s.requires_arc = true

  s.dependency "Alipay-SDK"

end
