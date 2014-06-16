require 'spec_helper'

describe 'Apache Service' do
  %w(8080).each do |port|
    describe port(port) do
      it { is_expected.to be_listening }
    end
  end

  describe service('apache2') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
end

describe 'Apache Virtual Hosts' do
  apache_dir = '/etc/apache2'

  %w(deflate expires headers rewrite).each do |mod|
    describe file("#{apache_dir}/mods-enabled/#{mod}.load") do
      it { is_expected.to be_linked_to("../mods-available/#{mod}.load") }
    end
  end

  describe file("#{apache_dir}/ports.conf") do
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    it { is_expected.to be_mode '644' }

    describe '#content' do
      subject { super().content }
      it { is_expected.to match(/Listen \*:8080\nNameVirtualHost \*:8080/) }
    end
  end

  describe file("#{apache_dir}/conf.d/h5bp.conf") do
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    it { is_expected.to be_mode '644' }
  end

  docroot = '/var/www/accounts.evertrue.com'

  describe file(docroot) do
    it { is_expected.to be_directory }
    it { is_expected.to be_owned_by 'deploy' }
    it { is_expected.to be_grouped_into 'www-data' }
    it { is_expected.to be_mode '2775' }
  end

  describe file("#{apache_dir}/sites-enabled/accounts.conf") do
    it { is_expected.to be_linked_to('../sites-available/accounts.conf') }
  end

  describe file("#{apache_dir}/sites-available/accounts.conf") do
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    it { is_expected.to be_mode '644' }

    describe '#content' do
      subject { super().content }
      it { is_expected.to include 'ServerName local-accounts.evertrue.com' }
    end

    describe '#content' do
      subject { super().content }
      it { is_expected.to include "DocumentRoot #{docroot}" }
    end
  end
end

describe 'Supporting functionality for accounts' do
  describe package('git') do
    it { is_expected.to be_installed }
  end

  %w(node npm bower grunt).each do |bin|
    describe command("which #{bin}") do
      describe '#stdout' do
        subject { super().stdout }
        it { is_expected.to include bin }
      end
    end
  end
end
