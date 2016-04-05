Pod::Spec.new do |s|
  s.name             = "PATabbarView"
  s.version          = "0.1.0"
  s.summary          = "Pushable Tabbar Like MacOS Safari"

  s.description      = <<-DESC
Pushable Tabbar is like MacOS Safari.You can add subclass of PATabbarPushedView object into PATabbarView.
                       DESC

  s.homepage         = "https://github.com/suterusu/PATabbarView"
  s.license          = 'MIT'
  s.author           = { "Inba" => "gyuuuuchan@gmail.com" }
  s.source           = { :git => "https://github.com/suterusu/PATabbarView.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Class/*'
  s.public_header_files = 'Class/PATabbarView.h','Class/PATabbarPushedView.h'


end
