require 'hashie/mash'
require_relative 'ocsp_helpers'

module ExtensionsHolder
  class << self
    def extensions
      @extensions ||= begin
        path = Rails.root.join('config', 'extensions.yaml.erb')
        yaml_config = YAML.safe_load(ERB.new(File.read(path)).result)
        Hashie::Mash.new(yaml_config)
      end
    end

    def extensions_for(name)
      extensions.send(name)
    end
  end
end
