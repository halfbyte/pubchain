module Bookbake
  class FileNotFoundError < StandardError
    def initialize(file)
      @file = file
    end
  end
end