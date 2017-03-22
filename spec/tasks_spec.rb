describe 'certificate_authority:create_certificates' do
  include_context 'rake'

  # redirect to tmp
  before do
    FileUtils.mkdir_p Rails.root.join('tmp', 'public')
    FileUtils.mkdir_p Rails.root.join('tmp', 'private')

    allow_any_instance_of(Pathname).to receive(:join).and_wrap_original do |m, *args|
      args.unshift('tmp') if %w(public private).include? args[0]
      m.call(*args)
    end
  end

  # helpers
  def get_cert(name)
    path = Rails.root.join('public', "#{name}.crt")
    OpenSSL::X509::Certificate.new File.read(path)
  end

  def get_key(name)
    path = Rails.root.join('private', "#{name}.key.pem")
    OpenSSL::PKey::RSA.new File.read(path), ENV['PASSWORD']
  end

  def get_cert_and_key(name)
    [get_cert(name), get_key(name)]
  end

  it '...' do
    subject.invoke

    root_cert, root_key   = get_cert_and_key('root')
    subca_cert, subca_key = get_cert_and_key('subca')
    ocsp_cert, ocsp_key   = get_cert_and_key('ocsp')

    certs = [root_cert, subca_cert, ocsp_cert]
    keys = [root_key, subca_key, ocsp_key]
    certs_and_keys = certs.zip(keys)

    certs_and_keys.each { |cert, key| expect(cert.check_private_key(key)).to be true }
    keys.each           { |key| expect(key.private?).to be true }

    # was singed by private_key that match to this public_key
    expect(root_cert.verify(root_cert.public_key)).to  eq true
    expect(subca_cert.verify(root_cert.public_key)).to eq true
    expect(ocsp_cert.verify(root_cert.public_key)).to  eq true
  end
end
