module OcspHelpers
  def make_ocsp_request(cert, issuer)
    cid = OpenSSL::OCSP::CertificateId.new(cert, issuer)
    request = OpenSSL::OCSP::Request.new.add_certid(cid)

    ocsp_uri = URI(ENV['DOMAIN'])
    http_resp = Net::HTTP.post(
      ocsp_uri,
      request.to_der,
      'Content-Type' => 'application/ocsp-response'
    )

    OpenSSL::OCSP::Response.new(http_resp.body)
  end
end

RSpec.configure do |config|
  config.include OcspHelpers
end
