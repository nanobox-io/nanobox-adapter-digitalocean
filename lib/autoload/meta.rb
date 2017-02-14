class Meta
  class << self
    def to_json
      {
        id:                'do',
        name:              'DigitalOcean',
        server_nick_name:  'Droplet',
        default_region:    'sfo2',
        default_plan:      'standard',
        default_size:      '512mb',
        ssh_user:          'root',
        internal_iface:    'eth1',
        external_iface:    'eth0',
        bootstrap_script:  'https://s3.amazonaws.com/tools.nanobox.io/bootstrap/ubuntu.sh',
        can_reboot:        true,
        can_rename:        true,
        credential_fields: [{ key: :access_token, label: 'Access Token' }],
        instructions:      instructions
      }.to_json
    end

    private

    def instructions
    <<-INSTR
<a href="//cloud.digitalocean.com/settings/api/tokens" target="_blank">Create
a Personal Access Token</a> in your Digital Ocean Account that has read/write
access, then add the token here or view the <a href="//www.digitalocean.com/
community/tutorials/how-to-use-the-digitalocean-api-v2#how-to-generate-a-
personal-access-token" target="_blank">full guide</a>
    INSTR
    end
  end
end
