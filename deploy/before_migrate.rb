Chef::Log.info("=== Hook: before_migrate for #{release_path}")
application="dcc"
deploy_user="deploy"
deploy_group="www-data"
shared_path = ::File.expand_path("#{node[:deploy][application][:deploy_to]}/shared")
Chef::Log.info("= Shared path is #{shared_path}")

Chef::Log.info("= Creating initializers Dir #{shared_path}/config/initializers")
directory ::File.expand_path("#{shared_path}/config/initializers") do
  mode 0770
  action :create
  recursive true
  owner deploy_user
  group deploy_group
end

["honeybadger","crm_credentials","dcc_api_key"].each do |config_name|
  release_config_path = "#{release_path}/config/initializers/#{config_name}.rb"
  Chef::Log.info("= Deleting default app config #{release_config_path}")
  file release_config_path do
    action :delete
    only_if { ::File.exists?("#{release_config_path}") }
  end
end

unless node[:deploy][application][:api_key].blank?
  Chef::Log.info("= Using template for dcc_api_key")
  template "#{shared_path}/config/initializers/dcc_api_key.rb" do
    local true
    owner deploy_user
    group deploy_group
    mode 0664
    variables(
      app_name: application
    )
    source "#{release_path}/deploy/templates/dcc_api_key.rb.erb"
  end
end

unless node[:deploy][application][:honeybadger][:api_key].blank?
  Chef::Log.info("= Using template for honeybadger")
  template "#{shared_path}/config/initializers/honeybadger.rb" do
    local true
    owner deploy_user
    group deploy_group
    mode 0664
    variables(
      app_name: application
    )
    source "#{release_path}/deploy/templates/honeybadger.rb.erb"
  end
end

unless node[:deploy][application][:webcrm][:api_key].blank?
  Chef::Log.info("= Using template for crm_credentials")
  template "#{shared_path}/config/initializers/crm_credentials.rb" do
    local true
    owner deploy_user
    group deploy_group
    mode 0664
    variables(
      app_name: application
    )
    source "#{release_path}/deploy/templates/crm_credentials.rb.erb"
  end
end

["honeybadger","crm_credentials","dcc_api_key"].each do |config_name|
  release_config_path = "#{release_path}/config/initializers/#{config_name}.rb"
  shared_config_path = "#{shared_path}/config/initializers/#{config_name}.rb"
  Chef::Log.info("= Link app config #{release_config_path} to #{shared_config_path}")
  link release_config_path do
    to shared_config_path
    owner deploy_user
    group deploy_group
  end
end
