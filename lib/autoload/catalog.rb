require 'droplet_kit'

class Catalog

  class << self
    def to_json
      memo = regions.map do |region|
        standard_plans = { id: 'standard', name: 'Standard', specs: [] }
        high_mem_plans = { id: 'high-mem', name: 'High Memory', specs: [] }
        region['sizes'].each do |size_slug|
          if size_slug.include?('m-')
            high_mem_plans[:specs] << catalog_size_specs(size_slug)
          else
            standard_plans[:specs] << catalog_size_specs(size_slug)
          end
        end
        memo = { id: region['slug'], name: region['name'], plans: [] }
        memo[:plans] << standard_plans if standard_plans[:specs].any?
        memo[:plans] << high_mem_plans if high_mem_plans[:specs].any?
        memo.with_indifferent_access
      end
      memo.sort_by { |r| r[:id] }.to_json
    end

    def sizes
      @sizes ||= begin
        puts 'INFO: retrieving sizes'
        JSON.parse(dk_client.sizes.all.to_json)
      end
    end

    def regions
      @regions ||= begin
        puts 'INFO: retrieving regions'
        JSON.parse(dk_client.regions.all.to_json)
      end
    end

    private

    def catalog_size_specs(size_slug)
      size_specs = sizes.find { |s| s['slug'] == size_slug }
      {
        id:             size_specs['slug'],
        ram:            size_specs['memory'],
        cpu:            size_specs['vcpus'],
        disk:           size_specs['disk'],
        transfer:       size_specs['transfer'],
        dollars_per_hr: size_specs['price_hourly'],
        dollars_per_mo: size_specs['price_monthly']
      }
    end

    def dk_client
      @dk_client ||= begin
        ::DropletKit::Client.new(access_token: ENV['ACCESS_TOKEN'])
      end
    end
  end
end
