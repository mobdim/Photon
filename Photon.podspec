Pod::Spec.new do |s|
  s.name         = 'Photon'
  s.version      = '0.0.1'
  s.license      = 'Apache'
  s.homepage     = 'http://loganscollins.com/'
  s.authors      = 'Logan Collins' # => 'dima@mobdim.com'
  s.summary      = 'Photon is a user interface toolkit for Mac OS X, with classes for common user interface idioms, such as iOS-style navigation and tab bars.'

# Source Info
  s.platform     =  :osx, '10.9'
  s.source       =  { :git => 'git@github.com:mobdim/Photon.git' }
  s.source_files = 'Photon/**/*.*'
#  s.framework    =  'Foundation', 'QuartzCore'

  s.requires_arc = true
end
