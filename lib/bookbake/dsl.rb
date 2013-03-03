module Bookbake
  module DSL
    SETTERS = [
      :author, :title, :version,
      :title_image, :chapters, :kramdown_options,
      :output_file_basename
    ]
    def method_missing(method, *params)
      if SETTERS.include?(method)
        Bookbake.application.book_options[method] = params[0]
      else
        super
      end
    end
  end
end

self.extend Bookbake::DSL
