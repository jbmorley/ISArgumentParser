Pod::Spec.new do |s|

  s.name         = "ISArgumentParser"
  s.version      = "0.0.1"
  s.summary      = "Objective-C command-line argument parser based heavily on Python's argparse"
  s.homepage     = "https://github.com/jbmorley/ISArgumentParser"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Jason Barrie Morley" => "jason.morley@inseven.co.uk" }
  s.source       = { :git => "https://github.com/jbmorley/ISArgumentParser.git", :commit => "6c95955958a3aa17799c8c2679a341106f7406fb" }

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'ISArgumentParser/*.{h,m}'

  s.requires_arc = true

  s.dependency 'ISUtilities', "~> 1.1"

end
