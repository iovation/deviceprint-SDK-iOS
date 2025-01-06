Pod::Spec.new do |s|
    s.name         = "DeviceRisk"
    s.version      = "5.6.0"
    s.summary      = "Device Risk SDK for iOS"
    s.description  = <<-DESC
    FraudForce is now Device Risk. Our device-based products, such as Device Risk and Device-Based Authentication 
    (formerly ClearKey), are critical components of our fraud and identity solutions; the new names make it easy 
    to quickly understand our extensive capabilities. We have united these solutions under the TransUnion 
    TruValidate brand. We have taken care not to update anything that might affect your implementations; as a 
    result you'll still see legacy names in some places.
    DESC
    s.homepage     = "https://www.iovation.com"
    s.author       = { "iovation" => "mark-sanvitale-iovation" }
    s.source       = { :git => "https://github.com/iovation/deviceprint-SDK-iOS.git", :tag => s.version.to_s }
    s.vendored_frameworks = "FraudForce.xcframework"
    s.platform = :ios
    s.swift_version = "5.0"
    s.ios.deployment_target  = '12.0'
end