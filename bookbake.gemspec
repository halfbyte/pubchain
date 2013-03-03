require File.expand_path('../lib/bookbake/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'bookbake'
  s.version     = Bookbake::VERSION
  s.date        = '2013-03-03'
  s.summary     = "markdown based book publishing toolchain"
  s.description = "An opinionated markdown based book publishing toolchain"
  s.authors     = ["Jan Krutisch"]
  s.email       = 'jan@krutisch.de'
  s.bindir      = "bin"
  s.executables << "bbake"
  s.files       = Dir["lib/**/*.rb"]
  s.license     = "MIT"
  s.homepage    = "http://github.com/halfbyte/bookbake"
  s.add_runtime_dependency("kramdown")
  s.add_runtime_dependency("coderay")
  s.add_runtime_dependency("nokogiri")
  s.add_runtime_dependency("tilt")
end