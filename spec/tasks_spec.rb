describe 'certificate_authority:populate_ca' do
  include_context 'rake'

  def get_cert_and_key(role)
    [Storage.load_cert(role), Storage.load_private_key(role)]
  end

  before do
    public_private = %w(public private)

    # clear
    public_private_tmp = public_private.map { |pp| Rails.root.join('tmp', pp) }
    public_private_tmp.each do |dir|
      FileUtils.rm_rf(dir)
      FileUtils.mkdir_p dir
    end

    # redirect to trash if starts with public or private
    allow_any_instance_of(Pathname).to receive(:join).and_wrap_original do |m, *args|
      args.unshift('tmp') if public_private.include? args[0]
      m.call(*args)
    end
  end

  it 'should generate valid certs and keys like in OpenSSL Cookbook' do
    subject.invoke

    root_cert, root_key   = get_cert_and_key('root')
    subca_cert, subca_key = get_cert_and_key('subca')
    ocsp_cert, ocsp_key   = get_cert_and_key('ocsp')

    certs = [root_cert, subca_cert, ocsp_cert]
    keys  = [root_key, subca_key, ocsp_key]
    certs_and_keys = certs.zip(keys)

    certs_and_keys.each { |cert, key| expect(cert.check_private_key(key)).to be true }
    keys.each           { |key| expect(key.private?).to be true }

    # was singed by private_key that match to this public_key
    expect(root_cert.verify(root_cert.public_key)).to  eq true
    expect(subca_cert.verify(root_cert.public_key)).to eq true
    expect(ocsp_cert.verify(root_cert.public_key)).to  eq true

    authorityInfoAccess = subca_cert.extensions.find { |ext| ext.oid == 'authorityInfoAccess' }
    expected = "CA Issuers - URI://localhost:3000/root.crt\nOCSP - URI://localhost:3000\n"
    expect(authorityInfoAccess.value).to eq expected
  end
end
