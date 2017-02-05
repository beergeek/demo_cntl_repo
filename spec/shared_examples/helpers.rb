require 'spec_helper'

shared_examples_for 'test_linux' do |fact_set|
  describe "Security Checks" do
    it { is_expected.to satisfy_file_resource_requirements }
  end

  describe "SOE Checks" do
    it do
      is_expected.to contain_class('firewall').with({
        'ensure' => 'running',
      })
    end

    it do
      is_expected.to contain_class('profile::firewall::pre')
    end

    it do
      is_expected.to contain_class('profile::firewall::post')
    end

    it do
      is_expected.to contain_class('profile::ssh')
    end

    it do
      is_expected.to contain_class('profile::sudo')
    end

    it do
      is_expected.to contain_class('profile::monitoring')
    end

    it do
      is_expected.to contain_class('profile::repos')
    end

    it do
      is_expected.to contain_class('profile::dns')
    end

    it do
      is_expected.to contain_firewall('100 allow ssh access').with({
        'dport'  => '22',
        'proto'  => 'tcp',
        'action' => 'accept',
      })
    end

    it do
      is_expected.to contain_file('/etc/issue').with({
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' => 'This system is the property of Puppet. Unauthorised access is not permitted',
      })
    end

    it do
      is_expected.to contain_file('/etc/issue.net').with({
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' => 'This system is the property of Puppet. Unauthorised access is not permitted',
      })
    end

    it do
      is_expected.to contain_class('ssh').with({
        'storeconfigs_enabled' => false,
        'options'              => {
          'Port'                            => '22',
          'AcceptEnv'                       => 'LANG LC_*',
          'ChallengeResponseAuthentication' => 'no',
          'PermitRootLogin'                 => 'yes',
          'PrintMotd'                       => 'no',
          'Subsystem'                       => 'sftp /usr/libexec/openssh/sftp-server',
          'UsePAM'                          => 'yes',
          'X11Forwarding'                   => 'yes',
          'RSAAuthentication'               => 'yes',
          'PubkeyAuthentication'            => 'yes',
          'AllowGroups'                     => ['root','vagrant','centos','ubuntu'],
        }
      })
    end

    it do
      is_expected.to contain_class('sudo').with({
        'purge'               => false,
        'config_file_replace' => true,
      })
    end

    it do
      is_expected.to contain_sudo__conf('centos').with({
        'priority'  => '10',
        'content'   => '%centos ALL=(ALL) NOPASSWD: ALL',
      })
    end

    it do
      is_expected.to contain_sudo('ubuntu').with({
        'priority'  => '10',
        'content'   => '%ubuntu ALL=(ALL) NOPASSWD: ALL',
      })
    end

    it do
      is_expected.to contain_sudo('vagrant').with({
        'priority'  => '10',
        'content'   => '%vagrant ALL=(ALL) NOPASSWD: ALL',
      })
    end
end
