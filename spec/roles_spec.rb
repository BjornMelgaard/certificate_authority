describe 'Roles' do
  before do
    root      = ca_factory_generate(:root)
    subca     = ca_factory_generate(:subca, root)
    developer = ca_factory_generate(:developer, subca)

    @root_cert, @root_key = root
    @subca_cert, @subca_key = subca
    @developer_cert, @developer_key = developer
  end

  context 'developer' do
    it 'have right OCSP URI' do
      ocsp_url = get_ocsp_url(@developer_cert)
      expect(ocsp_url).to eq 'OCSP - URI://localhost:3000'
    end

    it 'can create p7' do
      store = OpenSSL::X509::Store.new
      store.add_cert(@root_cert)
      store.add_cert(@subca_cert)
      ca_certs = [@root_cert]

      data = "aaaaa\r\nbbbbb\r\nccccc\r\n"
      tmp = OpenSSL::PKCS7.sign(@developer_cert, @developer_key, data, ca_certs)
      p7 = OpenSSL::PKCS7.new(tmp.to_der)
      assert p7.verify([], store)
    end

    it 'should be valid' do
      store = OpenSSL::X509::Store.new
      store.add_cert(@root_cert)
      assert store.verify(@developer_cert, [@subca_cert])
    end
  end
end
