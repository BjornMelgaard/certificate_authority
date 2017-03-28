require_relative 'storage'

class OcspMiddleware
  THIS_UPDATE = -1800
  NEXT_UPDATE = 3600
  OCSP_CERT   = Storage.load_cert(:ocsp)
  OCSP_KEY    = Storage.load_private_key(:ocsp)

  include OpenSSL::OCSP

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    return @app.call(@env) unless ocsp_request?

    return generate_http_response(RESPONSE_STATUS_MALFORMEDREQUEST) unless set_ocsp_request
    set_certificates
    generate_http_response(RESPONSE_STATUS_SUCCESSFUL, generate_basic_response)
  end

  private

  def generate_http_response(status, data = nil)
    response_der = OpenSSL::OCSP::Response.create(status, data).to_der
    headers = { 'CONTENT_TYPE' => 'application/ocsp-response',
                'CONTENT_LENGTH' => response_der.bytesize.to_s }
    [200, headers, [response_der]]
  end

  def ocsp_request?
    @env['REQUEST_METHOD'] == 'POST' && @env['CONTENT_TYPE'] == 'application/ocsp-request'
  end

  def set_ocsp_request
    @request = Request.new(@env['rack.input'].read)
  rescue OCSPError
    false
  end

  def set_certificates
    serials = @request.certid.map(&:serial).map(&:to_i)
    @certificates = Certificate.where(serial: serials)
  end

  def generate_basic_response
    br = BasicResponse.new
    add_statuses(br)
    br.copy_nonce(@request)
    br.sign(OCSP_CERT, OCSP_KEY)
  end

  def add_statuses(br)
    @request.certid.zip(@certificates).each do |certid, cert|
      br.add_status(certid,
                    cert.status,
                    cert.reason,
                    cert.revoked_at.to_i || 0,
                    THIS_UPDATE,
                    NEXT_UPDATE,
                    nil)
    end
  end
end
