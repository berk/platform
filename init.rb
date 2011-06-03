require 'pp'

[
 "lib/platform",
 "app/models/platform", 
 "app/models/platform/admin", 
 "app/models/platform/developers"
].each do |dir|
    Dir[File.expand_path("#{File.dirname(__FILE__)}/#{dir}/*.rb")].sort.each do |file|
      require_or_load file
    end
end
