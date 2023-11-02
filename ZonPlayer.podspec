Pod::Spec.new do |s|
  s.name             = 'ZonPlayer'
  s.version          = '0.1.0'
  s.summary          = '简单说明 ZonPlayer 的用途.'

  s.homepage         = 'https://git.17bdc.com/ios/ZonPlayer'
  s.author           = { 'Shanbay iOS' => 'ios@shanbay.com' }
  s.source           = { git: 'git@git.17bdc.com:ios/ZonPlayer.git', tag: s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'ZonPlayer/Classes/**/*.{swift}'
end
