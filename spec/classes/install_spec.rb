require 'spec_helper'

describe 'ncpa::install' do
  context 'with manage repo disabled' do
    let(:params) do
      {
        manage_repo: false,
        rpmrepo_url: 'http://repo.nagios.com',
      }
    end

    it 'compiles' do
      is_expected.to compile.with_all_deps
    end

    it 'does not contain the repo resource' do
      is_expected.not_to contain_package('nagios-repo')
    end

    it 'installs ncpa' do
      is_expected.to contain_package('ncpa').with(
        ensure: 'installed',
      )
    end
  end

  context 'with manage repo enabled' do
    let(:params) do
      {
        manage_repo: true,
        rpmrepo_url: 'https://repo.nagios.com/nagios/7/nagios-repo-7-3.el7.noarch.rpm',
      }
    end

    it 'compiles' do
      is_expected.to compile.with_all_deps
    end

    it 'contains the repo-package' do
      is_expected.to contain_package('nagios-repo').with(
        ensure: 'present',
        source: params[:rpmrepo_url],
        provider: 'rpm',
        before: 'Package[ncpa]',
      )
    end

    it 'installs ncpa' do
      is_expected.to contain_package('ncpa').with(
        ensure: 'installed',
      )
    end
  end
end
