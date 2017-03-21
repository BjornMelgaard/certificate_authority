describe 'certificate_authority:create_certificates' do
  include_context 'rake'

  it '...' do
    subject.invoke

    cert = OpenSSL::X509::Certificate.new File.read(CreateRoot::CERT_PATH)
    key = OpenSSL::PKey::RSA.new File.read(CreateRoot::KEY_PATH), ENV['PASSWORD']

    expect(cert.check_private_key(key)).to be true
  end
end
