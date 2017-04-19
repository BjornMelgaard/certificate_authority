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
    log_env
    ocsp_request? ? ocsp_response : @app.call(@env)
  end

  def ocsp_response
    set_ocsp_request
    return respond_with(RESPONSE_STATUS_MALFORMEDREQUEST) unless @request

    basic_responce = BasicResponse.new
    add_statuses(basic_responce)
    basic_responce.copy_nonce(@request)
    basic_responce.sign(ocsp_cert, ocsp_key)

    respond_with(RESPONSE_STATUS_SUCCESSFUL, basic_responce)
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
    @env['REQUEST_METHOD'] == 'POST' && \
      @env['CONTENT_TYPE'] == 'application/ocsp-request'
  end

  def set_ocsp_request
    @request = Request.new(@env['rack.input'].read)
  rescue OCSPError
    @request = nil
  end

  def add_statuses(basic_responce)
    certificates = certificates_from_request
    @request.certid.zip(certificates).each do |cid, cert|
      add_status(basic_responce, cid, cert)
    end
  end

  def certificates_from_request
    serials = @request.certid.map(&:serial).map(&:to_i)
    Certificate.where(serial: serials)
  end

  def add_status(basic_responce, cid, cert)
    status = cert&.status || V_CERTSTATUS_UNKNOWN
    reason = cert&.reason || REVOKED_STATUS_UNSPECIFIED
    revocation_time = cert&.revoked_at&.to_i || 0
    basic_responce.add_status(cid,
                              status,
                              reason,
                              revocation_time,
                              THIS_UPDATE,
                              NEXT_UPDATE,
                              nil)
  end

  def log_env
    Rails.logger.debug "OCSP Middleware: REQUEST_METHOD=#{@env['REQUEST_METHOD']}"
    Rails.logger.debug "OCSP Middleware: CONTENT_TYPE=#{@env['CONTENT_TYPE']}"
  end
end
