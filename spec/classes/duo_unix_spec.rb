require 'spec_helper'

describe 'duo_unix' do
  let(:params) do
    {
      'ikey'     => 'DIXXXXXXXXXXXXXXXXXX',
      'skey'     => 'X1hXztPX1rb1X71x1wXkpnmXXvqXXXqqj1XoXbbXu',
      'host'     => 'api-xxxxxxxx.duosecurity.com',
      'pushinfo' => 'yes',
    }
  end

  context 'on supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'when managing packages' do
          let(:params) do
            super().merge('manage_ssh' => true)
          end

          it { is_expected.to contain_package('openssh-server').with_ensure('installed') }

          case facts[:osfamily]
          when 'Debian'
            it { is_expected.to contain_class('duo_unix::apt') }
            it { is_expected.to contain_package('duo-unix').with_ensure('installed') }
            it {
              is_expected.to contain_service('ssh').with(
                ensure: 'running',
                enable: true,
              )
            }
          when 'RedHat'
            it { is_expected.to contain_class('duo_unix::yum') }
            it { is_expected.to contain_file('/etc/pki/rpm-gpg/DUO-GPG-PUBLIC-KEY') }
            it { is_expected.to contain_yumrepo('duosecurity') }
            it { is_expected.to contain_yumrepo('duosecurity').that_comes_before('Package[duo_unix]') }
            it { is_expected.to contain_package('duo_unix').with_ensure('installed') }
            it {
              is_expected.to contain_service('sshd').with(
                ensure: 'running',
                enable: true,
              )
            }
          end
        end

        it { is_expected.to contain_class('duo_unix::generic') }
        it { is_expected.to contain_file('/usr/sbin/login_duo') }

        context 'when usage: pam' do
          let(:params) do
            super().merge('usage' => 'pam')
          end

          it { is_expected.to contain_class('duo_unix::pam') }
          it { is_expected.to contain_file('/etc/duo/pam_duo.conf').with_content %r{^host=api-xxxxxxxx.duosecurity.com} }
          it {
            is_expected.to contain_augeas('Duo Security SSH Configuration').with_changes(
              ['set /files/etc/ssh/sshd_config/UsePAM yes',
               'set /files/etc/ssh/sshd_config/UseDNS no',
               'set /files/etc/ssh/sshd_config/ChallengeResponseAuthentication yes'],
            )
          }
          it { is_expected.to contain_augeas('PAM Configuration') }
          it { is_expected.to compile.with_all_deps }
        end

        context 'when usage: login' do
          let(:params) do
            super().merge('usage' => 'login')
          end

          it { is_expected.to contain_class('duo_unix::login') }
          it {
            is_expected.to contain_file('/etc/duo/login_duo.conf').with(
              'ensure' => 'present',
            )
          }
          it {
            is_expected.to contain_augeas('Duo Security SSH Configuration').with_changes(
              ['set /files/etc/ssh/sshd_config/ForceCommand /usr/sbin/login_duo',
               'set /files/etc/ssh/sshd_config/PermitTunnel no',
               'set /files/etc/ssh/sshd_config/AllowTcpForwarding no'],
            )
          }
          it { is_expected.to compile.with_all_deps }
        end
      end
    end
  end

  context 'when on an unsupported Operating System' do
    let(:facts) do
      {
        'os' => {
          'family' => 'MS-DOS',
        },
      }
    end

    it 'fails on unsupported OS' do
      expect { is_expected.to compile }.to raise_error(%r{does not support})
    end
  end
end
