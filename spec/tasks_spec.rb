describe 'certificate_authority:create_root' do
  include_context 'rake'

  it 'create cert' do
    subject.invoke

    cert = OpenSSL::X509::Certificate.new File.read(CreateRoot::CERT_PATH)
    key = OpenSSL::PKey::RSA.new File.read(CreateRoot::KEY_PATH), ENV['PASSWORD']

    expect(cert.check_private_key(key)).to be true
  end
end

describe 'certificate_authority:create_ca' do
  include_context 'rake'

  it 'create cert' do
    subject.invoke

    root_ca = OpenSSL::X509::Certificate.new File.read(CreateRoot::CERT_PATH)

    cert = OpenSSL::X509::Certificate.new File.read(CreateRoot::CERT_PATH)
    key = OpenSSL::PKey::RSA.new File.read(CreateRoot::KEY_PATH), ENV['PASSWORD']

    expect(cert.check_private_key(key)).to be true
  end
end
