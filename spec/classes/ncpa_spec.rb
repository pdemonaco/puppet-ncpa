require 'spec_helper'
require 'deep_merge'

missing_os_facts = {
  'Windows' => {
    kernel: 'windows',
    osfamily: 'windows',
    operatingsystem: 'windows',
  },
  'Generic-Linux' => {
    kernel: 'Linux',
    operatingsystem: 'SomeLinux',
  },
}

describe 'ncpa' do
  let(:params_base) do
    {
      community_string: 'mysecrettoken',
    }
  end
  let(:params_repo) do
    {
      manage_repo: true,
      rpmrepo_url: 'http://repo.internet.place.com',
    }
  end
  let(:params_windows) do
    {
      package_source: 'c:\temp\ncpa.exe',
    }
  end
  let(:params) { params_base }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      before(:each) do
        facts.deep_merge!(
          os: {
            family: facts[:osfamily],
            name: facts[:operatingsystem],
            release: {
              major: facts[:operatingsystemmajrelease],
            },
          },
        )
      end

      context 'with default values for all parameters' do
        it 'compiles with all dependencies' do
          is_expected.to compile.with_all_deps
        end

        it 'contains the NCPA subclasses' do
          is_expected.to contain_class('ncpa::install')
          is_expected.to contain_class('ncpa::config').that_requires('Class[ncpa::install]')
          is_expected.to contain_class('ncpa::service').that_subscribes_to('Class[ncpa::config]')
        end
      end

      if os_facts[:kernel] == 'Linux'
        context 'with manage repo enabled' do
          let(:params) do
            params_base.deep_merge!(params_repo)
          end

          it 'compiles with all dependencies' do
            is_expected.to compile.with_all_deps
          end
        end
      end
    end
  end

  missing_os_facts.each do |os, os_facts|
    context "on os #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        if os == 'Windows'
          params_base.deep_merge!(params_windows)
        else
          params_base
        end
      end

      it 'compiles with all dependencies' do
        is_expected.to compile.with_all_deps
      end

      it 'contains the NCPA subclasses' do
        is_expected.to contain_class('ncpa::install')
        is_expected.to contain_class('ncpa::config').that_requires('Class[ncpa::install]')
        is_expected.to contain_class('ncpa::service').that_subscribes_to('Class[ncpa::config]')
      end

      if os == 'Windows'
        it 'fails when package_source is missing!' do
          params[:package_source] = :undef
          is_expected.to compile.and_raise_error(%r{'package_source' must be specified on windows!})
        end
      end

      if os == 'Generic-Linux'
        it 'fails when rpmrepo_url is missing' do
          params[:manage_repo] = true
          is_expected.to compile.and_raise_error(%r{'rpmrepo_url' must be provided when 'manage_repo' is enabled!})
        end
      end
    end
  end
end
