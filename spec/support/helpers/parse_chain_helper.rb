module ParseChainHelper
  CHAIN_REGEX = /(-----BEGIN (X509 )?CERTIFICATE-----.+?-----END (X509 )?CERTIFICATE-----)/m

  def parse_chain(text)
    text.scan(CHAIN_REGEX).flatten.compact
  end
end

RSpec.configure do |config|
  config.include ParseChainHelper
end
