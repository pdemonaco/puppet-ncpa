require 'spec_helper'

describe 'ncpa' do
  let(:params) do
    {
      community_string: 'mysecrettoken',
    }
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
