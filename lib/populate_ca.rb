module PopulateCA
  class << self
    def call
      root = generate_and_store(:root, 'Root CA')
      generate_and_store(:subca, 'Sub CA', root)
      generate_and_store(:ocsp, 'OCSP Root Responder', root)
    end

    def generate_and_store(role, common_name, parent = nil)
      distinguished_name = "CN=#{common_name}/O=Sleepless Students/C=UA"

      cert = CA::Certificate.new
      cert.parent = parent
      cert.extensions = ExtensionsHolder.extensions_for(role)
      cert.subject = OpenSSL::X509::Name.parse distinguished_name
      cert.generate_key_material
      cert.sign!

      Storage.store_cert(role, cert)
      Storage.store_private_key(role, cert.private_key)

      cert
    end
  end
end
