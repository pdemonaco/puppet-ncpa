require 'spec_helper'

describe 'ncpa' do
  context 'with default values for all parameters' do
    it 'compiles with all dependencies' do
      is_expected.to compile.with_all_deps
    end

    it 'contains the NCPA class' do
      is_expected.to contain_class('ncpa')
    end
  end
end
