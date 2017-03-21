module CreateCertificates
  class << self
    def call
      root_cert, root_key = generate(:root)

      store_cert('root.crt', root_cert)
      store_private_key('root.key.pem', root_key)

      sub_cert, sub_key = generate_subca(root_cert)
      store_cert('subca.crt', sub_cert)
      store_private_key('subca.key.pem', sub_key)
    end

    def generate(type, parent = nil)
      config = config(type)
      keypair = OpenSSL::PKey::RSA.new(2048)

      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = SecureRandom.random_number(2**128 - 1)
      cert.not_before = Time.zone.now
      cert.not_after = cert.not_before.advance(years: 1)
      cert.public_key = keypair.public_key

      cert.subject = OpenSSL::X509::Name.parse config(type).distinguished_name
      cert.issuer = parent.name || cert.subject

      ef = OpenSSL::X509::ExtensionFactory.new # why do we need factory?
      ef.subject_certificate = cert
      ef.issuer_certificate = parent || cert

      config[:critical_extensions].each do |oid, value|
        cert.add_extension ef.create_extension(oid, value, true)
      end

      config[:non_critical_extensions].each do |oid, value|
        cert.add_extension ef.create_extension(oid, value, false)
      end

      cert.sign(keypair, OpenSSL::Digest::SHA256.new)
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
        path = Root.join('lib', 'certificates.yaml.erb')
        YAML.safe_load(ERB.new(File.read(path).result))
      end
    end
  end
end
