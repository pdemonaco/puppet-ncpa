require 'spec_helper'
require 'deep_merge'

kernels = {
  'Linux' => {
    kernel: 'Linux',
  },
  'Windows' => {
    kernel: 'windows',
    osfamily: 'windows',
    operatingsystem: 'windows',
  },
}

describe 'ncpa::install' do
  let(:param_map) do
    {
      'Linux' => {
        manage_repo: false,
        rpmrepo_url: 'http://repo.nagios.com',
        package_version: 'installed',
        package_source: '/some/unused/value',
      },
      'Windows' => {
        manage_repo: false,
        rpmrepo_url: 'http://i.dont.care.com',
        package_version: 'installed',
        package_source: 'c:\temp\ncpa.exe',
      },
    }
  end

  kernels.each do |name, facts|
    context "on kernel #{name}" do
      let(:facts) { facts }
      let(:params) { param_map[name] }

      context 'with manage repo disabled' do
        before(:each) do
          params.deep_merge!(
            manage_repo: false,
          )
        end

        it 'compiles' do
          is_expected.to compile.with_all_deps
        end

        it 'does not contain the repo resource' do
          is_expected.not_to contain_package('nagios-repo')
        end

        it 'installs ncpa' do
          package_name = if facts[:kernel] == 'windows'
                           'NCPA'
                         else
                           'ncpa'
                         end
          package_parameters = case facts[:kernel]
                               when 'windows'
                                 {
                                   ensure: params[:package_version],
                                   source: params[:package_source],
                                 }
                               when 'Linux'
                                 {
                                   ensure: params[:package_version],
                                 }
                               end
          is_expected.to contain_package(package_name).with(
            package_parameters,
          )
        end
      end

      context 'with manage repo enabled' do
        before(:each) do
          params.deep_merge!(
            manage_repo: true,
          )
        end

        it 'compiles' do
          is_expected.to compile.with_all_deps
        end

        if name == 'Linux'
          it 'contains the repo-package' do
            is_expected.to contain_package('nagios-repo').with(
              ensure: 'present',
              source: params[:rpmrepo_url],
              provider: 'rpm',
              before: 'Package[ncpa]',
            )
          end
        else
          it 'does not contain the repo-package' do
            is_expected.not_to contain_package('nagios-repo')
          end
        end

        it 'installs ncpa' do
          package_name = if facts[:kernel] == 'windows'
                           'NCPA'
                         else
                           'ncpa'
                         end
          package_parameters = case facts[:kernel]
                               when 'windows'
                                 {
                                   ensure: params[:package_version],
                                   source: params[:package_source],
                                 }
                               when 'Linux'
                                 {
                                   ensure: params[:package_version],
                                 }
                               end
          is_expected.to contain_package(package_name).with(
            package_parameters,
          )
        end
      end
    end
  end
end
