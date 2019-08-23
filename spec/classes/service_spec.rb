require 'spec_helper'

describe 'ncpa::service' do
  it 'compiles' do
    is_expected.to compile
  end

  it 'declares both services' do
    ['ncpa_listener', 'ncpa_passive'].each do |service|
      is_expected.to contain_service(service).with(
        ensure: 'running',
        enable: true,
      )
    end
  end
end
