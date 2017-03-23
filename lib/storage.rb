module Storage
  CERT_DIR = Rails.root.join('public')
  KEY_DIR  = Rails.root.join('private')

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
      CERT_DIR.join("#{role}.crt")
    end

    def key_path(role)
      KEY_DIR.join("#{role}.key.pem")
    end
  end
end
