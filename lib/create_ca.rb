module CreateCA
  CERT_PATH = Rails.root.join('public', 'root.crt')
  KEY_PATH  = Rails.root.join('private', 'root.key.pem')

  class << self
    def call
      cert, private_key = generate
      key_secure = private_key.export OpenSSL::Cipher.new('AES-128-CBC'), ENV['PASSWORD']

      open(CERT_PATH, 'w') { |io| io.write cert.to_pem }
      open(KEY_PATH,  'w') { |io| io.write key_secure }
    end

    def generate
      keypair = OpenSSL::PKey::RSA.new(2048)

      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = SecureRandom.random_number(2**128 - 1)
      cert.not_before = Time.zone.now
      cert.not_after = cert.not_before.advance(years: 1)
      cert.public_key = keypair.public_key

      cert.subject = OpenSSL::X509::Name.parse 'CN=Sub CA/O=Sleepless Students/C=UA'
      cert.issuer = cert.subject
      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = cert
      cert.add_extension(ef.create_extension('basicConstraints', 'CA:TRUE', true))
      cert.add_extension(ef.create_extension('keyUsage', 'keyCertSign, cRLSign', true))
      cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash'))
      cert.sign(keypair, OpenSSL::Digest::SHA256.new)

      [cert, keypair]
    end
  end
end
