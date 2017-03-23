module PopulateCA
  class << self
    def call
      root  = generate(:root, 'Root CA')
      subca = generate(:subca, 'Sub CA', parent: root)
      ocsp  = generate(:ocsp, 'OCSP Root Responder', parent: root)

      [root, subca, ocsp].each { |cert| store(cert) }
    end

    def generate(role, common_name, parent: nil)
      distinguished_name = "CN=#{common_name}/O=Sleepless Students/C=UA"

      cert = OpensslShim::Certificate.new(role, parent: parent)
      cert.subject = OpenSSL::X509::Name.parse distinguished_name
      cert.generate_key_material
      cert.sign!
      p cert
      cert
    end

    def store(cert)
      role = cert.role

      # store cert
      cert_path = Rails.root.join('public', "#{role}.crt")
      open(cert_path, 'w') { |io| io.write cert.to_pem }

      # store key
      key_path = Rails.root.join('private', "#{role}.key.pem")
      key_secure = cert.private_key.export(OpenSSL::Cipher.new('AES-128-CBC'), ENV['PASSWORD'])
      open(key_path, 'w') { |io| io.write key_secure }
    end
  end
end
