Pod::Spec.new do |s|
  s.name             = 'ZonPlayer'
  s.version          = '0.1.0'
  s.summary          = 'A library for player in iOS.'

  s.homepage         = 'https://git.17bdc.com/ios/ZonPlayer'
  s.author           = { 'ZeroOnet' => 'git@github.com:ZeroOnet/ZonPlayer.git' }
  s.source           = { git: 'git@github.com:ZeroOnet/ZonPlayer.git', tag: s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'ZonPlayer/Classes/**/*.{swift}'
end
