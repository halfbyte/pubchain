require 'bookbake/errors'
require 'bookbake/application'
require 'bookbake/bakefile'
require 'bookbake/book'
require 'bookbake/dsl'


module Bookbake
  class << self
    def application
      @application ||= Bookbake::Application.new
    end
  end
end