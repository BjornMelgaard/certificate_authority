module CreateCertificates
  class << self
    def call
      root_data = generate_and_store('root')
      generate_and_store('subca', root_data)
      generate_and_store('ocsp', root_data)
    end

    def generate_and_store(name, parent_data = nil)
      cert, priv_key = generate(name, parent_data)
      store_cert("#{name}.crt", cert)
      store_private_key("#{name}.key.pem", priv_key)
      [cert, priv_key]
    end

    def generate(name, parent_data = nil)
      parent_cert, parent_priv_key = parent_data
      conf = config[name]
      keypair = OpenSSL::PKey::RSA.new(2048)

      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = SecureRandom.random_number(2**128 - 1)
      cert.not_before = Time.zone.now
      cert.not_after = cert.not_before.advance(years: 1)
      cert.public_key = keypair.public_key

      cert.subject = OpenSSL::X509::Name.parse conf['distinguished_name']
      cert.issuer = parent_cert&.subject || cert.subject

      ef = OpenSSL::X509::ExtensionFactory.new # why do we need factory?
      ef.subject_certificate = cert
      ef.issuer_certificate = parent_cert || cert

      conf['critical_extensions'].each do |oid, value|
        cert.add_extension ef.create_extension(oid, value, true)
      end

      conf['non_critical_extensions'].each do |oid, value|
        cert.add_extension ef.create_extension(oid, value, false)
      end

      cert.sign(parent_priv_key || keypair, OpenSSL::Digest::SHA256.new)
      [cert, keypair]
    end

    def store_cert(name, cert)
      path = Rails.root.join('public', name)
      open(path, 'w') { |io| io.write cert.to_pem }
    end

    def store_private_key(name, key)
      key_secure = key.export OpenSSL::Cipher.new('AES-128-CBC'), ENV['PASSWORD']
      path = Rails.root.join('private', name)
      open(path, 'w') { |io| io.write key_secure }
    end

    private

    def config
      @config ||= begin
        path = Rails.root.join('config', 'certificates.yaml.erb')
        YAML.safe_load(ERB.new(File.read(path)).result)
      end
    end
  end
end
