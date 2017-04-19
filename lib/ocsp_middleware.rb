require_relative 'storage'

class OcspMiddleware
  THIS_UPDATE = -1800
  NEXT_UPDATE = 3600

  include OpenSSL::OCSP

  def self.ocsp_cert
    @ocsp_cert ||= Storage.load_cert(:ocsp)
  end

  def self.ocsp_key
    @ocsp_key ||= Storage.load_private_key(:ocsp)
  end

  delegate :ocsp_cert, :ocsp_key, to: :class

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    return @app.call(@env) unless ocsp_request?
    ocsp_response
  end

  def ocsp_response
    return respond_with(RESPONSE_STATUS_MALFORMEDREQUEST) unless set_ocsp_request
    set_certificates

    @br = BasicResponse.new
    @request.certid.zip(@certificates).each { |cid, cert| add_status(cid, cert) }
    @br.copy_nonce(@request)
    @br.sign(ocsp_cert, ocsp_key)

    respond_with(RESPONSE_STATUS_SUCCESSFUL, @br)
  rescue
    respond_with(RESPONSE_STATUS_INTERNALERROR)
  end

  private

  def respond_with(status, data = nil)
    response_der = OpenSSL::OCSP::Response.create(status, data).to_der
    headers = { 'CONTENT_TYPE' => 'application/ocsp-response',
                'CONTENT_LENGTH' => response_der.bytesize.to_s }
    [200, headers, [response_der]]
  end

  def ocsp_request?
    Rails.logger.debug @env['REQUEST_METHOD']
    Rails.logger.debug @env['CONTENT_TYPE']
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

  def add_status(cid, cert)
    status = cert&.status || V_CERTSTATUS_UNKNOWN
    reason = cert&.reason || REVOKED_STATUS_UNSPECIFIED
    revocation_time = cert&.revoked_at&.to_i || 0
    @br.add_status(cid, status, reason, revocation_time, THIS_UPDATE, NEXT_UPDATE, nil)
  end
end
