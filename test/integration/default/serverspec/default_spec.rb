require 'spec_helper'

describe 'Apache Service' do
  %w(8080).each do |port|
    describe port(port) do
      it { should be_listening }
    end
  end

  describe service('apache2') do
    it { should be_running }
    it { should be_enabled }
  end
end

describe 'Apache Virtual Hosts' do
  apache_dir = '/etc/apache2'

  %w(deflate expires headers rewrite).each do |mod|
    describe file("#{apache_dir}/mods-enabled/#{mod}.load") do
      it { should be_linked_to("../mods-available/#{mod}.load") }
    end
  end

  describe file("#{apache_dir}/ports.conf") do
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode '644' }
    its(:content) { should match(/Listen \*:8080\nNameVirtualHost \*:8080/) }
  end

  describe file("#{apache_dir}/conf.d/h5bp.conf") do
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode '644' }
  end

  docroot = '/var/www/accounts.evertrue.com'

  describe file(docroot) do
    it { should be_directory }
    it { should be_owned_by 'deploy' }
    it { should be_grouped_into 'www-data' }
    it { should be_mode '2775' }
  end

  describe file("#{apache_dir}/sites-enabled/accounts.conf") do
    it { should be_linked_to('../sites-available/accounts.conf') }
  end

  describe file("#{apache_dir}/sites-available/accounts.conf") do
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode '644' }
    its(:content) { should include 'ServerName local-accounts.evertrue.com' }
    its(:content) { should include "DocumentRoot #{docroot}" }
  end
end

describe 'Supporting functionality for accounts' do
  describe package('git') do
    it { should be_installed }
  end

  %w(node npm bower grunt).each do |bin|
    describe command("which #{bin}") do
      its(:stdout) { should include bin }
    end
  end
end
