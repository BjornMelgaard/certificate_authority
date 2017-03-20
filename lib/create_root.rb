module CreateRoot
  def self.call
    keypair = OpenSSL::PKey::RSA.new(2048)
    save_private_key keypair

    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = SecureRandom.random_number(2**128 - 1)
    cert.not_before = Time.zone.now
    cert.not_after = cert.not_before.advance(years: 1)
    cert.public_key = keypair.public_key

    cert.subject = OpenSSL::X509::Name.parse 'CN=Root CA/O=Sleepless Students/C=UA'
    cert.issuer = cert.subject
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert
    cert.add_extension(ef.create_extension('basicConstraints', 'CA:TRUE', true))
    cert.add_extension(ef.create_extension('keyUsage', 'keyCertSign, cRLSign', true))
    cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash', false))
    cert.add_extension(ef.create_extension('authorityKeyIdentifier', 'keyid:always', false))
    cert.sign(keypair, OpenSSL::Digest::SHA256.new)
  end

  def save_private_key(keypair)
    # keypair.to_pem
  end
end
