require 'droplet_kit'

class Client

  attr_reader :access_token

  def initialize(access_token)
    @access_token = access_token
  end

  def verify
    dk_client.account.info
  end

  def keys
    dk_client.ssh_keys.all.map(&:to_h)
  end

  def key(id)
    dk_client.ssh_keys.find(id: id).to_h
  end

  def key_create(id, public_key)
    key = DropletKit::SSHKey.new(name: id, public_key: public_key)
    dk_client.ssh_keys.create(key).id
  end

  def key_delete(id)
    dk_client.ssh_keys.delete(id: id)
  end

  def servers
    dk_client.droplets.all.map { |d| process_server(d) }
  end

  def server(id)
    process_server dk_client.droplets.find(id: id)
  end

  def server_order(attrs)
    attrs['ssh_keys']           = [attrs.delete('ssh_key').to_i]
    attrs['image']              = 'ubuntu-14-04-x64'
    attrs['private_networking'] = true

    droplet = DropletKit::Droplet.new(attrs)
    dk_client.droplets.create(droplet).id
  end

  def server_delete(id)
    dk_client.droplets.delete(id: id)
  end

  def server_reboot(id)
    dk_client.droplet_actions.reboot(droplet_id: id)
  end

  def server_rename(id, name)
    dk_client.droplet_actions.rename(droplet_id: id, name: name)
  end

  # def server_start(id)
  #   action = dk_client.droplet_actions.power_on(id: id)
  #   action.is_a?(DropletKit::Action) ? action : fail(action)
  # end

  # def server_stop(id)
  #   action = dk_client.droplet_actions.power_off(id: id)
  #   action.is_a?(DropletKit::Action) ? action : fail(action)
  # end

  private

  def process_server(droplet)
    s = {
      id:     droplet.id,
      name:   droplet.name,
      status: droplet.status
    }

    external_ip = network_ip('public', droplet)
    internal_ip = network_ip('private', droplet)

    s[:external_ip] = external_ip if external_ip
    s[:internal_ip] = internal_ip if internal_ip
    s
  end

  def network_ip(type, droplet)
    networks = droplet.networks.v4
    network = networks.find { |n| n.type == type }
    return unless network
    network.ip_address
  end

  def dk_client
    @dk_client ||= begin
      ::DropletKit::Client.new(access_token: access_token)
    end
  end
end
