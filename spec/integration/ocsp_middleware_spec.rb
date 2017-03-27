describe 'OcspMiddleware', type: :feature do
  before do
    @issuer_cert = load_cert(:subca)
    @issuer_key  = load_private_key(:subca)
    @developer_cert, @developer_key = ca_factory_generate(:developer, [@issuer_cert, @issuer_key])
    Certificate.create_from_certificate(@developer_cert)
  end

  it 'respond with status VALID if exists' do
    resp = make_ocsp_request(@developer_cert, @issuer_cert)

    subca = load_cert('sub-ca.crt')
    root = load_cert('root-ca.crt')
    cert = load_cert('server.crt')

    cid = OpenSSL::OCSP::CertificateId.new(cert, subca)
    request = OpenSSL::OCSP::Request.new.add_certid(cid)

    # with post, work
    ocsp_uri = URI('http://127.0.0.1:9080/')
    http_resp = Net::HTTP.post(ocsp_uri, request.to_der, 'Content-Type' => 'application/ocsp-response')

    resp = OpenSSL::OCSP::Response.new(http_resp.body)

    assert_equal resp.status, OpenSSL::OCSP::RESPONSE_STATUS_SUCCESSFUL
    assert resp.basic.is_a? OpenSSL::OCSP::BasicResponse

    first_cert_id = resp.basic.status[0][0]
    assert first_cert_id.cmp(cid)
    assert first_cert_id.cmp_issuer(cid)
    assert_equal first_cert_id.serial, cert.serial

    resp.basic.responses.each do |resp|
      assert resp.is_a? OpenSSL::OCSP::SingleResponse
      assert resp.check_validity
    end

    store = OpenSSL::X509::Store.new
    store.add_cert(cert)
    store.add_cert(subca)
    store.add_cert(root)
    assert resp.basic.verify([], store)
  end
end
