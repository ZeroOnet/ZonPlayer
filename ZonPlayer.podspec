Pod::Spec.new do |s|
  s.name             = 'ZonPlayer'
  s.version          = '1.0.0'
  s.summary          = 'A library for player in iOS.'
  s.homepage         = 'https://github.com/ZeroOnet/ZonPlayer'
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { 'ZeroOnet' => 'zeroonetworkspace@gmail.com' }
  s.social_media_url = "https://github.com/ZeroOnet"

  s.source           = { git: 'https://github.com/ZeroOnet/ZonPlayer.git', tag: s.version.to_s }

  s.swift_version = "6.0"
  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/**/*.{swift}'
end
