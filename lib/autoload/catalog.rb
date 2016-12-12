require 'droplet_kit'

class Catalog

  SIZES_PATH   = 'lib/autoload/catalog/sizes.json'.freeze
  REGIONS_PATH = 'lib/autoload/catalog/regions.json'.freeze

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
      parse_file(SIZES_PATH)
    end

    def regions
      parse_file(REGIONS_PATH)
    end

    def update
      puts 'updating catalog...'

      f = File.open(SIZES_PATH, 'w')
      f << client.sizes.all.to_json
      f.close
      puts "updated sizes: #{SIZES_PATH}"

      f = File.open(REGIONS_PATH, 'w')
      f << client.regions.all.to_json
      f.close
      puts "updated regions: #{SIZES_PATH}"

      puts 'done.'
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

    def parse_file(path)
      contents = File.open(path, 'r').read
      JSON.parse(contents) unless contents.empty?
    end

    def client
      @client ||= Client.new(ENV['ACCESS_TOKEN'])
    end
  end
end
