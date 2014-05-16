
require 'minitest/spec'

def assert_include_content(file, content)
  assert File.read(file).include?(content), "Expected file '#{file}' to include the specified content #{content}"
end

describe_recipe 'cookbook-qubell-broadleaf::add-solr-support' do
end
