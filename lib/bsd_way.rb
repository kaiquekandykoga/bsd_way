require 'yaml'
require 'pathname'
require 'json'
require 'net/http'

module BSDWay
  DATA_DIR    = Pathname.new(__dir__).parent.join('data')
  README_PATH = DATA_DIR.parent.join('README.md')

  OLLAMA_URL   = 'http://localhost:11434/api/generate'
  OLLAMA_MODEL = 'phi4:14b'

  PROVIDER_LABEL = 'Ollama (local)'

  def self.start(_args)
    generate
  end

  private_class_method def self.generate
    content = build_readme
    README_PATH.write(content)
    puts "Generated #{README_PATH}"
  end

  private_class_method def self.build_readme
    cloud_providers   = YAML.load_file(DATA_DIR.join('cloud_providers.yml'))
    sites             = YAML.load_file(DATA_DIR.join('sites.yml'))
    operating_systems = YAML.load_file(DATA_DIR.join('operating_systems.yml'))
    youtube_channels  = YAML.load_file(DATA_DIR.join('youtube_channels.yml'))

    prompt = <<~PROMPT
      Generate a well-structured README.md for a BSD resources repository.

      IMPORTANT: The very first line must be this notice (fill in the model):
      > 🤖 **AI-Generated** · Provider: #{PROVIDER_LABEL} · Model: `#{OLLAMA_MODEL}`

      IMPORTANT: Keep the output compact and concise. Use bullet points and brief notes only.
      IMPORTANT: Return raw Markdown only. Do NOT wrap output in ```markdown or any code fences. Do NOT add any closing notes or commentary after the content.

      Include:
      - Title and one-line description
      - Table of contents
      - Cloud Providers (with BSD versions and verification dates)
      - Sites
      - Operating Systems (with compatibility notes)
      - YouTube Channels

      Format nicely with Markdown. Use the data below:

      ### Cloud Providers
      #{cloud_providers.inspect}

      ### Sites
      #{sites.inspect}

      ### Operating Systems
      #{operating_systems.inspect}

      ### YouTube Channels
      #{youtube_channels.inspect}
    PROMPT

    raw = call_ollama(prompt).strip
    strip_fences(raw)
  end

  private_class_method def self.strip_fences(text)
    text = text.sub(/\A```(?:markdown)?\n/, '')
    text = text.sub(/```.*\z/m, '')
    text.strip
  end

  private_class_method def self.call_ollama(prompt)
    uri = URI(OLLAMA_URL)

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = JSON.generate({
      model:  OLLAMA_MODEL,
      prompt: prompt,
      stream: false
    })

    response = Net::HTTP.start(uri.host, uri.port, read_timeout: 600) do |http|
      http.request(request)
    end

    body = JSON.parse(response.body)
    raise "Ollama error: #{body['error']}" if body['error']

    body['response']
  end
end
