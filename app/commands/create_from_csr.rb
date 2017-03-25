class CreateFromCsr < Rectify::Command
  def initialize(params)
    @params = params
  end

  def call
    broadcast(:invalid, ['Invalid csr']) unless set_csr
    generate_certificate
    save_certificate

    broadcast(:ok, certificate_chain)
  end

  private

  def set_csr
    csr = OpenSSL::X509::Request.new(@params[:csr])
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
    [@certificate, subca_cert].map(&:to_pem)
  end
end
