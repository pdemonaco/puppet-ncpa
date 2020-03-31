require 'spec_helper'
require 'deep_merge'

weird_os_list = [
  'Windows',
]

describe 'ncpa' do
  let(:params) do
    {
      community_string: 'mysecrettoken',
    }
  end
  let(:missing_os_facts) do
    {
      'Windows' => {
        kernel: 'windows',
        osfamily: 'windows',
        operatingsystem: 'windows',
      },
    }
  end

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
    end
  end

  weird_os_list.each do |weird_os| 
    let(:facts) { missing_os_facts[weird_os] }

    context "on weird os #{weird_os}" do
      it 'compiles with all dependencies' do
        is_expected.to compile.with_all_deps
      end

      it 'contains the NCPA subclasses' do
        is_expected.to contain_class('ncpa::install')
        is_expected.to contain_class('ncpa::config').that_requires('Class[ncpa::install]')
        is_expected.to contain_class('ncpa::service').that_subscribes_to('Class[ncpa::config]')
      end
    end
  end
end
