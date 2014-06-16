require 'spec_helper'

describe 'et_accounts_app::default' do
  let(:chef_run) do
    ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04') do |node|
      node.set['apache']['root_group'] = 'root'
      node.set['et_accounts_app']['deploy_to'] = '/var/www/accounts.evertrue.com'
      node.set['apache']['group'] = 'www-data'
      node.set['apache']['dir'] = '/etc/apache2'
    end.converge(described_recipe)
  end

  before do
    stub_command('[ -f /usr/local/share/node-version ] && [ "$(git rev-parse HEAD)" = "$(cat /usr/local/share/node-version)" ]').and_return(true)
  end

  %w(
    apt::default
    node::default
    et_users::evertrue
    apache2::default
  ).each do |recipe|
    it "includes #{recipe}" do
      expect(chef_run).to include_recipe recipe
    end
  end

  it 'installs git' do
    expect(chef_run).to install_package 'git'
  end

  it 'creates /etc/apache2/conf.d/h5bp.conf' do
    expect(chef_run).to create_cookbook_file_if_missing('/etc/apache2/conf.d/h5bp.conf').with(
      user: 'root',
      group: 'root',
      mode: '0644'
    )
  end

  %w(/var/www/accounts.evertrue.com).each do |path|
    it "creates directory #{path}" do
      expect(chef_run).to create_directory(path).with(
        user: 'deploy',
        group: 'www-data',
        mode: '2775'
      )
    end
  end
end
