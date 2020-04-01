require 'spec_helper'

describe 'ncpa::config' do
  let(:params) do
    {
      manage_firewall: false,
      port: 5693,
      community_string: 'my-awesome-community',
      install_dir: '/usr/local/ncpa',
      plugin_dir: 'plugins/',
      plugin_files: [],
    }
  end

  it 'compiles' do
    is_expected.to compile.with_all_deps
  end

  it 'creates the ncpa.conf file' do
    is_expected.to contain_file('/usr/local/ncpa/etc/ncpa.cfg').with(
      ensure: 'file',
      mode: '0644',
      owner: 'root',
      group: 'nagios',
    )
  end

  it 'configures the group & community string' do
    content = catalogue.resource('file', '/usr/local/ncpa/etc/ncpa.cfg').send(:parameters)[:content]
    expect(content).to match(%r{community_string = #{params[:community_string]}})
    expect(content).to match(%r{port = #{params[:port]}})
    expect(content).to match(%r{plugin_path = #{params[:plugin_dir]}})
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

  context 'including plugin files' do
    before(:each) do
      params.merge!(
        plugin_files: [
          {
            name: 'check_multipath.py',
            content: 'puppet:///module_specific/ncpa/check_multipath.py',
          },
          {
            name: 'check_honeypot_files.py',
            content: '/tmp/check_honeypot_files.py',
          },
          {
            name: 'honeycomb.tsv',
            content: 'https://some-server.org/honeycomb.tsv',
          },
        ],
      )
    end

    it 'installs the plugin files in the plugin dir' do
      files = params[:plugin_files]
      ncpa_dir = params[:install_dir]
      plugin_dir = params[:plugin_dir]
      plugin_path = "#{ncpa_dir}/#{plugin_dir}"
      is_expected.to contain_file(plugin_path).with(
        ensure: 'directory',
        mode: '0755',
        owner: 'root',
        group: 'nagios',
      )
      files.each do |entry|
        filename = entry[:name]
        content = entry[:content]
        target_path = "#{ncpa_dir}/#{plugin_dir}/#{filename}"
        is_expected.to contain_file(target_path).with(
          ensure: 'file',
          mode: '0644',
          owner: 'root',
          group: 'nagios',
          source: content,
          require: "File[#{plugin_path}]",
        )
      end
    end
  end
end
