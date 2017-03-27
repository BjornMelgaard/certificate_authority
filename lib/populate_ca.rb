module PopulateCA
  class << self
    def call
      root_data  = generate_and_store(:root, 'Root CA')
      subca_data = generate_and_store(:subca, 'Sub CA', root_data)
      generate_and_store(:ocsp, 'OCSP Root Responder', subca_data)
    end

    def generate_and_store(role, common_name, parent_data = nil)
      distinguished_name = "CN=#{common_name}/O=Sleepless Students/C=UA"

      generator = CertificateFactory.new(role)
      generator.subject = OpenSSL::X509::Name.parse distinguished_name

      if parent_data.nil?
        generator.selfsign!
      else
        generator.sign_by!(*parent_data)
      end

      Storage.store_cert(role, generator.certificate)
      Storage.store_private_key(role, generator.private_key)

      [generator.certificate, generator.private_key]
    end
  end
end
