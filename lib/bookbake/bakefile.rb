module Bookbake
  module Bakefile
    class << self
      def load_bakefile(path)
        puts "path: #{path}"
        load(path)
      end
    end
  end
end
