require 'rubygems'
require 'bundler/setup'

require 'redcarpet'
require 'yaml'

module Pubchain
  class Renderer < Redcarpet::Render::HTML

  end
end


desc "well"
task :r do
  manifest = YAML.load('testdata/manifest.yml')
  puts manifest
  md = Redcarpet::Markdown.new(Pubchain::Renderer)
  manifest['files'].each do |filename|
    File.open("testdata/#{filename}", "r") do |file|
      puts md.render(file.read())
    end
  end



end