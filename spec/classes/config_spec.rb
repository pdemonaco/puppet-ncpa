require 'spec_helper'
require 'deep_merge'

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

describe 'ncpa::config' do
  let(:params_base) do
    {
      manage_firewall: false,
      port: 5693,
      community_string: 'my-awesome-community',
      plugin_files: [],
    }
  end
  let(:params_linux) do
    {
      install_dir: '/usr/local/ncpa',
      plugin_dir: 'plugins/',
    }
  end
  let(:params_windows) do
    {
      install_dir: 'C:/Program Files (x86)/Nagios/NCPA',
      plugin_dir: 'plugins/',
    }
  end
  let(:plugin_files_linux) do
    {
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
    }
  end
  let(:plugin_files_windows) do
    {
      plugin_files: [
        {
          name: 'check_multipath.py',
          content: 'puppet:///module_specific/ncpa/check_multipath.py',
        },
        {
          name: 'check_honeypot_files.py',
          content: 'c:/temp/check_honeypot_files.py',
        },
        {
          name: 'honeycomb.tsv',
          content: 'https://some-server.org/honeycomb.tsv',
        },
      ],
    }
  end
  let(:file_permissions) do
    {
      'Windows' => {
        dir: {
          ensure: 'directory',
          owner: 'Administrators',
        },
        file: {
          ensure: 'file',
          owner: 'Administrators',
        },
      },
      'Generic-Linux' => {
        dir: {
          ensure: 'directory',
          mode: '0755',
          owner: 'root',
          group: 'nagios',
        },
        file: {
          ensure: 'file',
          mode: '0644',
          owner: 'root',
          group: 'nagios',
        },
      },
    }
  end

  os_list.each do |os, os_facts|
    context "on os #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        params_os = case os
                    when 'Windows'
                      params_windows
                    when 'Generic-Linux'
                      params_linux
                    end
        params_base.deep_merge!(params_os)
      end

      before(:each) do
        # See https://github.com/rodjek/rspec-puppet/issues/665 for context
        # This lets linux fake it till it makes it
        if os == 'Windows'
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(Puppet::Type.type(:acl).provider(:windows)).to receive(:validate)
          # rubocop:enable RSpec/AnyInstance
        end
      end

      it 'compiles' do
        is_expected.to compile.with_all_deps
      end

      it 'creates the ncpa.conf file' do
        file_properties = file_permissions[os][:file]
        is_expected.to contain_file("#{params[:install_dir]}/etc/ncpa.cfg").with(
          file_properties,
        )
      end

      it 'configures the group & community string' do
        content = catalogue.resource('file', "#{params[:install_dir]}/etc/ncpa.cfg").send(:parameters)[:content]
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

        if os == 'Generic-Linux'
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
        else
          it 'does nothing' do
            is_expected.not_to contain_class('firewalld')
            is_expected.not_to contain_firewalld__custom_service('ncpa_listener')
            is_expected.not_to contain_firewalld_service('Nagios Cross Platform Agent Listener Traffic')
          end
        end
      end

      context 'including plugin files' do
        before(:each) do
          plugin_files = case os
                         when 'Windows'
                           plugin_files_windows
                         when 'Generic-Linux'
                           plugin_files_linux
                         end
          params.merge!(plugin_files)
        end

        it 'installs the plugin files in the plugin dir' do
          files = params[:plugin_files]
          ncpa_dir = params[:install_dir]
          plugin_dir = params[:plugin_dir]
          plugin_path = "#{ncpa_dir}/#{plugin_dir}"
          dir_properties = file_permissions[os][:dir]
          is_expected.to contain_file(plugin_path).with(
            dir_properties,
          )
          files.each do |entry|
            filename = entry[:name]
            content = entry[:content]
            target_path = "#{ncpa_dir}/#{plugin_dir}/#{filename}"
            file_properties = file_permissions[os][:file].merge(
              source: content,
              require: "File[#{plugin_path}]",
            )
            is_expected.to contain_file(target_path).with(
              file_properties,
            )
          end
          if os == 'Windows'
            is_expected.to contain_acl(plugin_path).with(
              inherit_parent_permissions: true,
            )
          end
        end
      end
    end
  end
end
