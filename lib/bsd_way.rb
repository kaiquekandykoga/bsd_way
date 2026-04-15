require 'yaml'
require 'pathname'

module BSDWay
  DATA_DIR = Pathname.new(__dir__).parent.join('data')
  README_PATH = DATA_DIR.parent.join('README.md')

  def self.start(_args)
    generate
  end

  private_class_method def self.generate
    content = build_readme
    README_PATH.write(content)
    puts "Generated #{README_PATH}"
  end

  private_class_method def self.build_readme
    <<~MD
      # BSD Way

      A repository of BSD resources, roadmaps, and other relevant materials, curated based on personal research and preferences

      * [Cloud Providers](#cloud-providers)
      * [Sites](#sites)
      * [Operating Systems](#operating-systems)
      * [YouTube Channels](#youtube-channels)

      ## Cloud Providers

      A list of cloud providers offering BSD systems. Not all providers listed have been personally tested.

      #{cloud_providers_section}

      ## Sites

      #{sites_section}

      ## Operating Systems

      ThinkPad models are generally an excellent choice for running BSD systems, but I've also had reasonably good success getting FreeBSD working on a Dell laptop

      #{operating_systems_section}

      ## YouTube Channels

      #{youtube_channels_section}
    MD
  end

  private_class_method def self.cloud_providers_section
    items = YAML.load_file(DATA_DIR.join('cloud_providers.yml'))
    items.map do |item|
      notes = item['notes'] ? " → #{item['notes']} (verified on #{item['verified_date']})" : ''
      "* [#{item['name']}](#{item['url']})#{notes}"
    end.join("\n")
  end

  private_class_method def self.sites_section
    items = YAML.load_file(DATA_DIR.join('sites.yml'))
    items.map { |item| "* [#{item['name']}](#{item['url']})" }.join("\n")
  end

  private_class_method def self.operating_systems_section
    items = YAML.load_file(DATA_DIR.join('operating_systems.yml'))
    items.map do |item|
      notes = item['notes'] ? " → #{item['notes']}" : ''
      "* [#{item['name']}](#{item['url']})#{notes}"
    end.join("\n")
  end

  private_class_method def self.youtube_channels_section
    items = YAML.load_file(DATA_DIR.join('youtube_channels.yml'))
    items.map { |item| "* [#{item['name']}](#{item['url']})" }.join("\n")
  end
end
