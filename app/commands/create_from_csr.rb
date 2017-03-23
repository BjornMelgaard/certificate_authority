class CreateFromCsr < Rectify::Command
  def initialize(params)
    @params = params
  end

  def call
    broadcast(:invalid, ['Invalid csr']) unless set_csr
    set_openssl_certificate

    broadcast(:ok)
  end

  private

  def set_csr
    @csr = OpenSSL::X509::Request.new(@params[:csr])
    @csr.verify(@csr.public_key)
  rescue OpenSSL::X509::RequestError => e
    p e
    false
  end

  def set_openssl_certificate
    cert = OpensslShim::Sertificate.new(:server, parent: subca)
    cert.subject     = @csr.subject
    cert.public_key  = @csr.public_key
    cert.sign!
    cert
  end
end
