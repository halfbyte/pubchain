require 'rubygems'
require 'bundler/setup'

require 'redcarpet'
require 'yaml'
require 'tilt'
require 'fileutils'
require 'pygments'

module Pubchain

  class Renderer < Redcarpet::Render::HTML
    def block_code(code, language)
      Pygments.highlight(code, :lexer => language)
    end
  end

  class RenderContext

    def initialize(context = {})
      @context = context if context.is_a?(Hash)
    end

    def method_missing(name, *params)
      return @context[name] if @context[name]
      super
    end
  end

  class Book
    attr_reader :manifest, :layout, :markdown, :path
    def initialize(path)
      @path = path
      @manifest = YAML.load_file("#{path}/manifest.yml")
      @layout = Tilt.new("testdata/#{manifest['layout']}")
      @markdown = Redcarpet::Markdown.new(Renderer, fenced_code_blocks: true)
    end

    def files
      manifest['files'].map do |filename|
        File.open("#{path}/#{filename}", "r") do |file|
          markdown.render(file.read())
        end
      end
    end

    def render
      layout.render(RenderContext.new({files: files, pygments_css: Pygments.css('.hicks')}))
    end

    def render_to_file
      FileUtils.mkdir_p("#{path}/output")
      File.open("#{path}/output/book.html", 'w') do |file|
        file.write(render())
      end
    end

  end

end


book = Pubchain::Book.new('testdata')
book.render_to_file
