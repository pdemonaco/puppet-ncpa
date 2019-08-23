require 'spec_helper'

describe 'ncpa::config' do
  let(:params) do
    {
      manage_firewall: false,
      port: 5693,
      community_string: 'my-awesome-community',
    }
  end

  it 'compiles' do
    is_expected.to compile.with_all_deps
  end

  it 'creates the ncpa.conf file' do
    is_expected.to contain_file('/usr/local/ncpa/etc/ncpa.cfg').with(
      ensure: 'file',
      mode: '0644',
      owner: 'nagios',
      group: 'nagios',
    )
  end

  it 'configures the group & community string' do
    content = catalogue.resource('file', '/usr/local/ncpa/etc/ncpa.cfg').send(:parameters)[:content]
    expect(content).to match(%r{community_string = #{params[:community_string]}})
    expect(content).to match(%r{port = #{params[:port]}})
  end

  context 'managing firewall' do
    before(:each) do
      params.merge!(
        manage_firewall: true,
      )
    end

    it 'compiles' do
      is_expected.to compile.with_all_deps
    end

    it 'includes firewalld' do
      is_expected.to contain_class('firewalld')
    end

    it 'configures the relevant ports' do
      is_expected.to contain_firewalld__custom_service('ncpa_listener').with(
        description: 'Nagios Cross Platform Agent Listener Traffic',
        port: [
          {
            'port' => params[:port],
            'protocol' => 'tcp',
          },
        ],
      )
      is_expected.to contain_firewalld_service('Nagios Cross Platform Agent Listener Traffic').with(
        ensure: 'present',
        service: 'ncpa_listener',
        zone: 'public',
      )
    end
  end
end
