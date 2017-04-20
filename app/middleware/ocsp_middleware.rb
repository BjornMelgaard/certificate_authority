require_relative 'concerns/ocsp_cert_and_key'
require_relative 'concerns/ocsp_basic_responce_add_statuses'

class OcspMiddleware
  include OpenSSL::OCSP
  include OcspCertAndKey
  include OcspBasicResponceAddStatuses

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    log_env
    ocsp_request? ? ocsp_response : @app.call(@env)
  end

  def ocsp_response
    request = get_ocsp_request
    return respond_with(RESPONSE_STATUS_MALFORMEDREQUEST) unless request

    basic_responce = BasicResponse.new
    add_statuses(request, basic_responce)
    basic_responce.copy_nonce(request)
    basic_responce.sign(ocsp_cert, ocsp_key)

    respond_with(RESPONSE_STATUS_SUCCESSFUL, basic_responce)
  rescue
    respond_with(RESPONSE_STATUS_INTERNALERROR)
  end

  private

  def ocsp_request?
    @env['REQUEST_METHOD'] == 'POST' && @env['CONTENT_TYPE'] == 'application/ocsp-request'
  end

  def respond_with(status, data = nil)
    response_der = OpenSSL::OCSP::Response.create(status, data).to_der
    headers = { 'CONTENT_TYPE' => 'application/ocsp-response',
                'CONTENT_LENGTH' => response_der.bytesize.to_s }
    [200, headers, [response_der]]
  end

  def log_env
    Rails.logger.debug "OCSP Middleware: REQUEST_METHOD=#{@env['REQUEST_METHOD']}"
    Rails.logger.debug "OCSP Middleware: CONTENT_TYPE=#{@env['CONTENT_TYPE']}"
  end

  def get_ocsp_request
    Request.new(@env['rack.input'].read)
  rescue OCSPError
    nil
  end
end
