
# https://github.com/vagrant-libvirt/vagrant-libvirt#libvirt-configuration
VIRTUAL_MACHINE_BASE_NAME = 'devstation_'

VIRTUAL_MACHINES_GROUPS_DEF = [
    {
        count: 1,
        box: 'generic/rocky8',
        base_name: 'rocky_controller',
        username: 'dademo',
        #user_public_key: '~/.ssh/id_rsa.pub',
        user_public_key: '/resources/id_rsa.pub',
        machine: {
            memory: 1024,
            cpus: 2,
            storage_pool_name: 'external',
            storages: [
                {
                    size: '20G',
                },
            ],
            networks: [
                {
                    network_type: 'private_network',
                    libvirt__network_name: 'default',
                    type: 'dhcp',
                    model_type: 'virtio',
                    libvirt__forward_mode: 'nat',
                    libvirt__dhcp_enabled: true,
                    libvirt__guest_ipv6: false,
                    libvirt__always_destroy: false,
                }, {
                    network_type: 'private_network',
                    libvirt__network_name: 'intnet2',
                    type: 'dhcp',
                    model_type: 'virtio',
                    libvirt__forward_mode: 'nat',
                    libvirt__dhcp_enabled: false,
                    libvirt__guest_ipv6: false,
                    libvirt__always_destroy: false,
                }
            ],
            provision: [
                {
                    name: 'Updating the system',
                    type: 'shell',
                    privileged: true,
                    sensitive: false,
                    inline: 'dnf update -y',
                },
                {
                    name: 'Adding Python 3',
                    type: 'shell',
                    privileged: true,
                    sensitive: false,
                    inline: 'dnf install python3 -y',
                },
            ],
        },
    },
]
VIRTUAL_MACHINE_CREATE_USER = 'dademo'

Vagrant.configure('2') do |config|

    config.vm.provider :libvirt do |libvirt|
        libvirt.uri = 'qemu:///system'
        # libvirt.system_uri = 'qemu:///system'
        
        libvirt.nested = false
        libvirt.cpu_mode = 'host-model'
        libvirt.graphics_type = 'none'
        libvirt.keymap = 'fr-fr'
        libvirt.autostart = false

        libvirt.management_network_device = 'virbr0'
        libvirt_membaloon_enabled = true
    end

    VIRTUAL_MACHINES_GROUPS_DEF.each do |machine_group_def|

        (0..((machine_group_def[:count] || 1) - 1)).each do |it|

            final_vm_name = "#{VIRTUAL_MACHINE_BASE_NAME}_#{machine_group_def[:base_name]}_#{it}"

            config.vm.define final_vm_name do |machine|

                machine.vm.box = machine_group_def[:box]

                machine.vm.provider :libvirt do |libvirt|
                    libvirt.title = final_vm_name

                    if machine_group_def.key?('description')
                        libvirt.description = machine_group_def[:description]
                    end

                    libvirt.memory = machine_group_def[:machine][:memory] || 512
                    libvirt.cpus = machine_group_def[:machine][:cpus] || 2
                    libvirt.storage_pool_name = machine_group_def[:machine][:storage_pool_name] || 'external'
                    libvirt.disk_bus = machine_group_def[:machine][:disk_bus] || 'virtio'

                    (machine_group_def[:machine][:storages] || []).each do |storage|
                        libvirt.storage :file, **({
                            type: 'qcow2',
                            bus: 'virtio',
                        }.merge!(storage))
                    end
                end

                ((machine_group_def[:machine] || {})[:networks] || []).each do |network|
                    
                    _type = (network.delete(:network_type) || 'private_network')
                    machine.vm.network _type, **(network.merge!({
                        always_destroy: false,
                        libvirt__always_destroy: false
                    }))
                end

                config.vm.provision 'VIRTUAL_MACHINE_CREATE_USER',
                    type: 'shell',
                    name: 'Creating base group and users',
                    privileged: true,
                    sensitive: false,
                    inline: <<-SHELL
                        groupadd sudo || true
                        useradd -G users,wheel,sudo -m #{machine_group_def[:username]} || true
                    SHELL
                
                if machine_group_def.key?('user_public_key')

                    config.vm.provision 'copy_ssh_public_key',
                        type: 'file',
                        source: machine_group_def[:user_public_key],
                        destination: '/tmp/__work_id_rsa.pub'

                    config.vm.provision 'public_key_rights',
                        type: 'shell',
                        name: 'Assigning rihgts to the public key',
                        privileged: true,
                        sensitive: false,
                        inline: <<-SHELL
                            mkdir -pv /home/#{machine_group_def[:username]}/.ssh
                            mv -v /tmp/__work_id_rsa.pub /home/#{machine_group_def[:username]}/.ssh/authorized_keys
                            chown -Rv #{machine_group_def[:username]}:#{machine_group_def[:username]} /home/#{machine_group_def[:username]}/.ssh
                            chmod -v 700 /home/#{machine_group_def[:username]}/.ssh
                            chmod -v 644 /home/#{machine_group_def[:username]}/.ssh/authorized_keys
                        SHELL
                end
                
                (machine_group_def[:machine][:provision] || []).each do |provision|
                    _type = provision.delete(:type) || 'shell'
                    config.vm.provision _type, **provision
                end
            end
        end
    end
end
