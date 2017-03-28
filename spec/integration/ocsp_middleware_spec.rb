describe 'OcspMiddleware' do
  before do
    @root_cert = load_cert(:root)
    @ocsp_cert = load_cert(:ocsp)

    @issuer_cert = load_cert(:subca)
    @issuer_key  = load_private_key(:subca)

    @developer_cert, @developer_key = ca_factory_generate(:developer, [@issuer_cert, @issuer_key])
    @dev_cid = OpenSSL::OCSP::CertificateId.new(@developer_cert, @issuer_cert)
  end

  let(:app) { ->(env) { [200, env, 'app'] } }
  let(:middleware) { OcspMiddleware.new(app) }

  it 'respond with status VALID if exists' do
    Certificate.create_from_certificate(@developer_cert)

    code, env, body = middleware.call ocsp_env_for(@dev_cid)
    resp = OpenSSL::OCSP::Response.new(body[0])

    assert_equal resp.status, OpenSSL::OCSP::RESPONSE_STATUS_SUCCESSFUL
    assert resp.basic.is_a? OpenSSL::OCSP::BasicResponse

    resp.basic.status.each do |(_cid, status, reason)|
      assert_equal status, OpenSSL::OCSP::V_CERTSTATUS_GOOD
      assert_equal reason, OpenSSL::OCSP::REVOKED_STATUS_UNSPECIFIED
    end

    first_cert_id = resp.basic.status[0][0]
    assert first_cert_id.cmp(@dev_cid)
    assert first_cert_id.cmp_issuer(@dev_cid)
    assert_equal first_cert_id.serial, @developer_cert.serial

    resp.basic.responses.each do |resp|
      assert resp.is_a? OpenSSL::OCSP::SingleResponse
      assert resp.check_validity
    end

    store = OpenSSL::X509::Store.new
    store.add_cert(@issuer_cert)
    store.add_cert(@root_cert)
    assert resp.basic.verify([@ocsp_cert], store)
  end

  it 'respond with V_CERTSTATUS_UNKNOWN if not in database' do
    _code, _env, body = middleware.call ocsp_env_for(@dev_cid)
    resp = OpenSSL::OCSP::Response.new(body[0])

    assert_equal resp.status, OpenSSL::OCSP::RESPONSE_STATUS_SUCCESSFUL
    resp.basic.status.each do |(_cid, status, reason)|
      assert_equal status, OpenSSL::OCSP::V_CERTSTATUS_UNKNOWN
      assert_equal reason, OpenSSL::OCSP::REVOKED_STATUS_UNSPECIFIED
    end
  end

  it 'respond with V_CERTSTATUS_REVOKED if not in database' do
    cert = Certificate.create_from_certificate(@developer_cert)
    cert.revoke

    _code, _env, body = middleware.call ocsp_env_for(@dev_cid)
    resp = OpenSSL::OCSP::Response.new(body[0])

    assert_equal resp.status, OpenSSL::OCSP::RESPONSE_STATUS_SUCCESSFUL
    resp.basic.status.each do |(_cid, status, reason)|
      assert_equal status, OpenSSL::OCSP::V_CERTSTATUS_REVOKED
      assert_equal reason, OpenSSL::OCSP::REVOKED_STATUS_UNSPECIFIED
    end
  end
end
