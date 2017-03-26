describe 'OcspMiddleware', type: :feature do
  before do
    @issuer_cert = load_cert(:subca)
    @issuer_key  = load_private_key(:subca)
    @developer_cert, @developer_key = ca_factory_generate(:developer, [@issuer_cert, @issuer_key])
    Certificate.create_from_certificate(@developer_cert)
  end

  it 'respond with status VALID if exists' do
    resp = make_ocsp_request(@developer_cert, @issuer_cert)
  end
end
