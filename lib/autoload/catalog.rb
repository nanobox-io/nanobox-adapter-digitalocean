require 'droplet_kit'

class Catalog

  class << self
    def to_json
      @to_json ||= begin
        memo = regions.map do |region|
          standard_plans = { id: 'standard', name: 'Standard', specs: [] }
          # old pricing avail unil July 1st, 2018
          legacy_plans = { id: 'legacy', name: 'Legacy', specs: [] }
          high_mem_plans = { id: 'high-mem', name: 'High Memory', specs: [] }
          region['sizes'].each do |size_slug|
            size_specs = find_size_specs(size_slug)
            puts "WARNING: no size_specs for #{size_slug} in #{region['name']}"
            next unless size_specs
            if size_slug.include?('s-')
              standard_plans[:specs] << size_specs
              standard_plans[:specs].sort_by! { |r| r[:dollars_per_mo] }
            elsif size_slug.include?('m-')
              high_mem_plans[:specs] << size_specs
              high_mem_plans[:specs].sort_by! { |r| r[:dollars_per_mo] }
            else
              legacy_plans[:specs] << size_specs
              legacy_plans[:specs].sort_by! { |r| r[:dollars_per_mo] }
            end
          end
          memo = { id: region['slug'], name: region['name'], plans: [] }
          memo[:plans] << standard_plans if standard_plans[:specs].any?
          memo[:plans] << legacy_plans if legacy_plans[:specs].any?
          memo[:plans] << high_mem_plans if high_mem_plans[:specs].any?
          memo.with_indifferent_access
        end
        memo.sort_by { |r| r[:id] }.to_json
      end
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

    def find_size_specs(size_slug)
      size_specs = sizes.find { |s| s['slug'] == size_slug }
      return unless size_specs
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
