module Bookbake
  class Application
    attr_accessor :book_options
    def initialize
      @book_options = {}
    end

    def run
      path = File.join(Dir.pwd, 'Bakefile')
      unless File.exist?(path)
        puts "Bakefile not found"
        exit 10
      end
      puts "Using #{File.expand_path(path)}"
      Bakefile.load_bakefile(path)
      book = Book.new(Dir.pwd, book_options)
      book.render_to_file
    end
  end
end