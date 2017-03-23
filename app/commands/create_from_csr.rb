class CreateFromCsr < Rectify::Command
  def initialize(params)
    @params = params
  end

  def call
    broadcast(:invalid, ['Invalid csr']) unless set_csr
    set_certificate

    Certificate.create(pem: @cert.to_pem, serial: @cert.serial)
    broadcast(:ok)
  end

  private

  def set_csr
    @csr = OpenSSL::X509::Request.new(@params[:csr])
    @csr.verify(@csr.public_key)
  # rescue OpenSSL::X509::RequestError
  #   false
  end

  def set_certificate
    @cert = CA::Certificate.from_csr(@csr)
    @cert.extensions = ExtensionsHolder.extensions_for(:server)
    @cert.parent = issuer
    @cert.sign!
    @cert
  end
end
