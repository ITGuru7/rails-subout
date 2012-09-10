# First, load the definitions
Dir[File.join(File.dirname(__FILE__), '../dupe/*.rb')].each do |file|
  require file
end
