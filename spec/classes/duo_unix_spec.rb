require 'spec_helper'

describe 'duo_unix' do
  context 'on supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        let(:params) do
          {
            'ikey'     => 'DIXXXXXXXXXXXXXXXXXX',
            'skey'     => 'X1hXztPX1rb1X71x1wXkpnmXXvqXXXqqj1XoXbbXu',
            'host'     => 'api-xxxxxxxx.duosecurity.com',
            'pushinfo' => 'yes',
          }
        end

        context 'on usage: pam' do
          let(:params) do
            {
              'usage' => 'pam',
            }
          end

          it { is_expected.to contain_class('duo_unix::pam') }
          it {
            is_expected.to contain_file('/etc/duo/pam_duo.conf').with(
              'ensure' => 'file',
            )
          }
          it { is_expected.to compile.with_all_deps }
        end

        context 'on usage: login' do
          let(:params) do
            {
              'usage' => 'login',
            }
          end

          it { is_expected.to contain_class('duo_unix::login') }
          it {
            is_expected.to contain_file('/etc/duo/login_duo.conf').with(
              'ensure' => 'file',
            )
          }
          it { is_expected.to compile.with_all_deps }
        end
      end
    end
  end

  context 'on unsupported operating systems' do
    let(:facts) do
      {
        'osfamily' => 'Suse',
      }
    end

    it do
      expect {
        catalogue
      }.to raise_error(Puppet::Error, %r{Module duo_unix does not support})
    end
  end
end
