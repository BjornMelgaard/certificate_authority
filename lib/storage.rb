module Storage
  CERT_DIR = File.expand_path('../../public', __FILE__)
  KEY_DIR  = File.expand_path('../../private', __FILE__)

  class << self
    def store_cert(role, cert)
      open(cert_path(role), 'w') { |io| io.write cert.to_pem }
    end

    def store_private_key(role, key)
      key_secure = key.export(OpenSSL::Cipher.new('AES-128-CBC'), ENV['PASSWORD'])
      open(key_path(role), 'w') { |io| io.write key_secure }
    end

    def load_cert(role)
      OpenSSL::X509::Certificate.new(File.read(cert_path(role)))
    end

    def load_private_key(role)
      OpenSSL::PKey::RSA.new(File.read(key_path(role)), ENV['PASSWORD'])
    end

    def cert_path(role)
      File.join(CERT_DIR, "#{role}.crt")
    end

    def key_path(role)
      File.join(KEY_DIR, "#{role}.key.pem")
    end
  end
end
