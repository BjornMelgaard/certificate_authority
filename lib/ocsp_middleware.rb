include OpenSSL::OCSP

class OcspMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env)# if media_type != 'application/ocsp-request' && method != 'POST'
    p env
  end

  private

  def ocsp_request?

  end
end
