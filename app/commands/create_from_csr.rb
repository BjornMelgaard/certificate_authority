class CreateFromCsr < Rectify::Command
  def initialize(params)
    @params = params
  end

  def call
    set_csr
    return broadcast(:invalid, ['Invalid csr']) unless @csr
    generate_certificate
    broadcast(:ok, save_certificate)
  end

  private

  def set_csr
    csr = @params[:csr]
    csr = OpenSSL::X509::Request.new(csr)
    return unless csr.verify(csr.public_key)
    @csr = csr
  rescue OpenSSL::X509::RequestError
    @csr = nil
  end

  def generate_certificate
    generator = CertificateFactory.from_csr(:server, @csr)
    generator.sign_by!(subca_cert, subca_key)
    @certificate = generator.certificate
  end

  def save_certificate
    Certificate.create_from_certificate(@certificate)
  end
end
