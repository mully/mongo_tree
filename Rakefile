require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('mongo_tree', '0.1.0') do |p|
  p.description    = "Add hierarchy tree functionality to MongoRecord (MongoDB) models."
  p.url            = "http://github.com/mully/mongo_tree"
  p.author         = "Jim Mulhollnad"
  p.email          = "jim@squeejee.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
