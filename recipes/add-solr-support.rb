require 'digest'

case node['platform_family']
  when "debian"
    execute "update packages cache" do
      command "apt-get update"
    end
  end

package "unzip" do
  action :install
end

directory "#{node['cookbook-qubell-build']['target']}/WEB-INF/classes/runtime-properties" do 
  action :create
  recursive true
end

directory "#{node['cookbook-qubell-build']['target']}/WEB-INF" do
  action :create
end

template "#{node['cookbook-qubell-build']['target']}/WEB-INF/applicationContext.xml" do
      source "applicationContext.xml.erb"
      variables({
        :solr_url => node["cookbook-qubell-broadleaf"]["solr_url"].join(','),
        :solr_reindex_url => node["cookbook-qubell-broadleaf"]["solr_reindex_url"].join(',')
      })
    end

template "#{node['cookbook-qubell-build']['target']}/WEB-INF/classes/runtime-properties/common.properties" do
      source "common.properties.erb"
      variables({
        :solr_url => node["cookbook-qubell-broadleaf"]["solr_url"].join(',')
      })
    end

execute "upadte_war" do
    cwd "#{node['cookbook-qubell-build']['target']}"
    command "jar -uvf mycompany.war WEB-INF/applicationContext.xml"
    action :run
    not_if "unzip -p /tmp/mvn/mycompany.war* WEB-INF/applicationContext.xml| grep -q #{node['cookbook-qubell-broadleaf']['solr_url']}"
    notifies :run, "execute[backup_template]", :immediately
end

execute "backup_template" do
    cwd "#{node['cookbook-qubell-build']['target']}"
    command "cp -f WEB-INF/applicationContext.xml /tmp; cp -f WEB-INF/classes/runtime-properties/common.properties /tmp"
    action :nothing
end

directory "#{node['cookbook-qubell-build']['target']}/WEB-INF" do 
  action :delete
  recursive true
end

ruby_block "set attrs" do
  block do
    md5 = Digest::MD5.hexdigest File.read "/tmp/applicationContext.xml" 
    node.set['cookbook-qubell-broadleaf']['updated'] = md5
   end
end

