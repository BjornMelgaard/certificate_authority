module OcspHelpers
  def ocsp_env_for(cid)
    request = OpenSSL::OCSP::Request.new.add_certid(cid)
    Rack::MockRequest.env_for('/',
                              input: request.to_der,
                              method: 'POST',
                              'CONTENT_TYPE' => 'application/ocsp-request')
  end
end

RSpec.configure do |config|
  config.include OcspHelpers
end
