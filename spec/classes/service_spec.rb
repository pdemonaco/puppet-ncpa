require 'spec_helper'

os_list = {
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

describe 'ncpa::service' do
  os_list.each do |os, os_facts|
    context "on os #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          services: case os
                    when 'Windows'
                      ['ncpalistener', 'ncpapassive']
                    when 'Generic-Linux'
                      ['ncpa_listener', 'ncpa_passive']
                    end,
        }
      end

      it 'compiles' do
        is_expected.to compile
      end

      it 'declares both services' do
        mode = if facts[:kernel] == 'windows'
                 'delayed'
               else
                 'true'
               end
        params[:services].each do |service|
          is_expected.to contain_service(service).with(
            ensure: 'running',
            enable: mode,
          )
        end
      end
    end
  end
end
