FactoryGirl.define do
  factory :csr, class: OpenSSL::X509::Request do
    version 0
    subject { OpenSSL::X509::Name.parse 'CN=Maksim Developer/O=Maksim Org/C=UA' }

    transient do
      keypair { OpenSSL::PKey::RSA.new 2048 }
    end

    to_create do |csr, evaluator|
      csr.public_key = evaluator.keypair.public_key
      csr.sign evaluator.keypair, OpenSSL::Digest::SHA256.new
    end
  end
end

# csr_cert = OpenSSL::X509::Certificate.new
# csr_cert.serial = 0
# csr_cert.version = 2
# csr_cert.not_before = Time.now
# csr_cert.not_after = Time.now + 600
# csr_cert.public_key = csr.public_key
# csr_cert.subject = csr.subject
# csr_cert.issuer = ocsp_cert.subject
# ef = OpenSSL::X509::ExtensionFactory.new
# ef.subject_certificate = csr_cert
# ef.issuer_certificate = ocsp_cert

# csr_cert.add_extension ef.create_extension('basicConstraints', 'CA:FALSE')
# csr_cert.add_extension ef.create_extension('keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')
# csr_cert.add_extension ef.create_extension('subjectKeyIdentifier', 'hash')
# csr_cert.sign ocsp_key, OpenSSL::Digest::SHA256.new

# path = Rails.root.join('public', 'maks.crt')
# open(path, 'w') { |io| io.write csr_cert.to_pem }
