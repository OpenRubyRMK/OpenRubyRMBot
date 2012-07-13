# -*- ruby -*-
require "rake"
require "rake/clean"
require "rdoc/task"

RDoc::Task.new do |r|
  r.rdoc_files.include("lib/**/*.rb", "plugins/**/*.rb", "**/*.rdoc", "COPYING", "AUTHORS", "README")
  r.title    = "OpenRubyRMBot RDocs"
  r.main     = "README"
  r.rdoc_dir = "doc"
end
