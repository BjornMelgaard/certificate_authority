class CreateFromCsr < Rectify::Command
  def initialize(params)
    @params = params
  end

  def call
    broadcast(:invalid, ['Invalid csr']) unless set_csr
    set_certificate

    p7chain = OpenSSL::PKCS7.new
    p7chain.type = 'signed'
    p7chain.certificates = [@certificate, subca_cert]

    broadcast(:ok, p7chain, store_certificate)
  end

  private

  def set_csr
    csr = OpenSSL::X509::Request.new(@params[:csr])
    return false unless csr.verify(csr.public_key)
    @csr = csr
  rescue OpenSSL::X509::RequestError
    return false
  end

  def set_certificate
    generator = CertificateGenerator.from_csr(:server, @csr)
    generator.sign_by!(subca_cert, subca_key)
    @certificate = generator.certificate
  end

  def store_certificate
    Certificate.create(pem: @certificate.to_pem, serial: @certificate.serial)
  end
end
