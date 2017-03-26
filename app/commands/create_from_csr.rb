class CreateFromCsr < Rectify::Command
  def initialize(params, request)
    @format = request.format.symbol
    @raw_csr = request.raw_post if @format == :text
  end

  def call
    return broadcast(:invalid, 'Invalid format') unless @format == :text
    return broadcast(:invalid, 'Invalid csr') unless set_csr
    generate_certificate
    save_certificate

    broadcast(:ok, certificate_chain)
  end

  private

  def set_csr
    csr = OpenSSL::X509::Request.new(@raw_csr)
    return false unless csr.verify(csr.public_key)
    @csr = csr
  rescue OpenSSL::X509::RequestError
    return false
  end

  def generate_certificate
    generator = CertificateFactory.from_csr(:server, @csr)
    generator.sign_by!(subca_cert, subca_key)
    @certificate = generator.certificate
  end

  def save_certificate
    Certificate.create_from_certificate(@certificate)
  end

  def certificate_chain
    [@certificate, subca_cert].map { |cert| cert_to_text(cert) }.join("\n")
  end

  def cert_to_text(cert)
    header = %i(subject issuer).map do |attr|
      "#{attr}=#{cert.send(attr)}"
    end
    [header, cert.to_pem].flatten.join("\n")
  end
end
