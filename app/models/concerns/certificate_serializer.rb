class CertificateSerializer
  def self.load(pem)
    OpenSSL::X509::Certificate.new(pem)
  end

  def self.dump(cert)
    cert.to_pem
  end
end
