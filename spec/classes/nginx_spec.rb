require 'spec_helper'

describe 'nginx' do
  let :params do
    {
      :nginx_upstreams => { 'upstream1' => { 'members' => ['localhost:3000']} },
      :nginx_vhosts    => { 'test2.local' => { 'www_root' => '/' } },
      :nginx_locations => { 'test2.local' => { 'vhost' => 'test2.local', 'www_root' => '/'} },
      :nginx_mailhosts => { 'smtp.test2.local' => { 'auth_http' => 'server2.example/cgi-bin/auth', 'protocol' => 'smtp', 'listen_port' => 587} }
    }
  end

  shared_examples "a Linux OS" do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('nginx') }
    it { is_expected.to contain_anchor('nginx::begin') }
    it { is_expected.to contain_nginx__package.that_requires('Anchor[nginx::begin]') }
    it { is_expected.to contain_nginx__config.that_requires('Class[nginx::package]') }
    it { is_expected.to contain_nginx__service.that_subscribes_to('Anchor[nginx::begin]') }
    it { is_expected.to contain_nginx__service.that_subscribes_to('Class[nginx::package]') }
    it { is_expected.to contain_nginx__service.that_subscribes_to('Class[nginx::config]') }
    it { is_expected.to contain_anchor('nginx::end').that_requires('Class[nginx::service]') }
    it { is_expected.to contain_class("nginx::params") }
    it { is_expected.to contain_nginx__resource__upstream("upstream1") }
    it { is_expected.to contain_nginx__resource__vhost("test2.local") }
    it { is_expected.to contain_nginx__resource__location("test2.local") }
    it { is_expected.to contain_nginx__resource__mailhost("smtp.test2.local") }
  end

  context "Debian OS" do
    it_behaves_like "a Linux OS" do
      let :facts do
        {
          :operatingsystem => 'Debian',
          :osfamily        => 'Debian',
          :lsbdistcodename => 'precise',
          :lsbdistid       => 'Debian',
        }
      end
    end
  end

  context "RedHat OS" do
    it_behaves_like "a Linux OS" do
      let :facts do
        {
          :operatingsystem => 'RedHat',
          :osfamily        => 'RedHat',
        }
      end
    end
  end

  context "Suse OS" do
    it_behaves_like "a Linux OS" do
      let :facts do
        {
          :operatingsystem => 'SuSE',
          :osfamily        => 'Suse',
        }
      end
    end
  end
end
