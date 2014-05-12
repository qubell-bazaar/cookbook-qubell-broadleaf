service "tomcat" do
  service_name "tomcat#{node["tomcat"]["base_version"]}"
  supports :restart => false, :status => true
  action :nothing
end

directory "#{node['build']['target']}/WEB-INF" do 
  action :create
end

template "#{node['build']['target']}/WEB-INF/applicationContext.xml" do
      source "applicationContext.xml.erb"
      variables({
        :solr_url => node["broadleaf"]["solr_url"],
        :solr_reindex_url => node["broadleaf"]["solr_reindex_url"]
      })
    end
execute "upadte_war" do
    cwd "#{node['build']['target']}"
    command "jar -uvf mycompany.war WEB-INF/applicationContext.xml"
    action :run
end

directory "#{node['build']['target']}/WEB-INF" do 
  action :delete
  recursive true
end
