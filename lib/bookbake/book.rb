require 'rubygems'
require 'bundler/setup'

# require 'redcarpet'
require 'kramdown'
require 'yaml'
require 'tilt'
require 'fileutils'
require 'nokogiri'

module Bookbake

  # class Renderer < Redcarpet::Render::HTML
  #   def block_code(code, language)
  #     begin
  #       Pygments.highlight(code, :lexer => language)
  #     rescue MentosError => e
  #       puts "ERROR"
  #       puts code
  #       return code
  #     end
  #   end
  # end

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
    attr_reader :manifest, :layout, :markdown, :path, :options
    def initialize(path, opts={})
      @path = path
      @options = {
        layout: 'layout.erb',
        title: 'That book',
        author: 'That Author',
        output_filename_base: "book",
        chapters: [],
        kramdown_options: {
          enable_coderay: true,
          auto_ids: true,
          parse_block_html: true,
          coderay_line_numbers: nil
        }
      }.merge(opts)
      @layout = Tilt.new("#{path}/#{@options[:layout]}")
    end

    def chapters
      return [] if options[:chapters].empty?
      options[:chapters].map do |filename|
        chapter_id = File.basename(filename, '.md')
        doc = ""
        File.open("#{path}/#{filename}", "r") do |file|
          doc = Kramdown::Document.new(
            file.read(),
            options[:kramdown_options].merge(auto_id_prefix: "#{chapter_id}_")
          ).to_html
        end
        {contents: doc, id: chapter_id}
      end
    end

    def render
      chaps = chapters()
      layout.render(RenderContext.new({chapters: chapters, title: options[:title]}))
    end

    def render_to_file
      FileUtils.mkdir_p("#{path}/output")
      File.open("#{path}/output/#{options[:output_filename_base]}.html", 'w') do |file|
        file.write(render())
      end
      @html_doc = Nokogiri::HTML(open("#{path}/output/book.html"))

      add_toc(@html_doc)
      File.open("#{path}/output/book.html", 'w') do |file|
        file.write(@html_doc.to_s)
      end
      collect_and_copy_assets_from_html(@html_doc)
    end

    def add_toc(doc)
      return unless toc = doc.css('section.toc').first
      data = []
      doc.css('section.chapter').each do |chapter|
        chapter_data = { id: chapter['id'], title: chapter.css('h1').first.content, sub: [] }
        chapter.css('h2').each do |sub|
          unless sub['class'] && sub['class'].match(/no-toc/)
            sub_data = { id: sub['id'], title: sub.content }
          end
          chapter_data[:sub] << sub_data
        end
        data << chapter_data
      end
      markup = "<ol class='toc-list'>" + data.map { |chapter|
        "<li><a href='##{chapter[:id]}'>#{chapter[:title]}</a><ol>" +
        chapter[:sub].map { |sub|
          "<li><a href='##{sub[:id]}'>#{sub[:title]}</a></li>"
        }.join("") + "</ol>"
      }.join("") + "</ol>"
      toc << markup
    end

    def copy_file(file, prefix = "")
      if File.exist?(File.join(path,prefix, file))
        dir = File.dirname(file)
        FileUtils.mkdir_p(File.join(path, 'output', prefix, dir))
        FileUtils.cp(File.join(path, prefix, file), File.join(path, 'output', prefix, file))
        puts "copied #{File.join(path, prefix, file)}:#{File.join(path, 'output', prefix, file)}"
      end
    end
    def collect_and_copy_assets_from_css(css_path)
      css = File.read(File.join(path, css_path))
      dir = File.dirname(css_path)
      css.scan(/url\((.+?)\)/) do |matches|
        copy_file(matches.first, dir)
      end

    end
    def collect_and_copy_assets_from_html(doc)
      # stylesheets
      doc.css("link[rel='stylesheet']").each do |link|
        css_path = link['href']
        copy_file(css_path)
        collect_and_copy_assets_from_css(css_path)
      end
      doc.css("img[src]").each do |img|
        img_path = link['src']
        copy_file(img_path)
      end
      doc.css("style").each do |style_block|
        style_block.content.scan(/url\((.+?)\)/) do |matches|
          copy_file(matches.first)
        end
      end
    end
  end
end