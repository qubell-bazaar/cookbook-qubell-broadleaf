case node['platform_family']
  when "debian"
    execute "update packages cache" do
      command "apt-get update"
    end
  end

package "unzip" do
  action :install
end

directory "#{node['cookbook-qubell-build']['target']}/WEB-INF" do 
  action :create
end

template "#{node['cookbook-qubell-build']['target']}/WEB-INF/applicationContext.xml" do
      source "applicationContext.xml.erb"
      variables({
        :solr_url => node["cookbook-qubell-broadleaf"]["solr_url"],
        :solr_reindex_url => node["cookbook-qubell-broadleaf"]["solr_reindex_url"]
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
    command "cp -f WEB-INF/applicationContext.xml /tmp"
    action :nothing
end

directory "#{node['cookbook-qubell-build']['target']}/WEB-INF" do 
  action :delete
  recursive true
end
