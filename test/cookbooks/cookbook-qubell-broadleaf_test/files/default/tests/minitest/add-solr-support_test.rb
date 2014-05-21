
require 'minitest/spec'

def assert_include_content(file, content)
  assert File.read(file).include?(content), "Expected file '#{file}' to include the specified content #{content}"
end

describe_recipe 'cookbook-qubell-broadleaf::add-solr-support' do
  
  it "create applicationContext.xml  with zoo nodes" do 
      file("/tmp/applicationContext.xml").must_exist
      assert_include_content("/tmp/applicationContext.xml", node['cookbook-qubell-broadleaf']['solr_url'])    
  end
   

end
