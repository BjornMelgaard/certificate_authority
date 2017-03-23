module CAStorage
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
end

RSpec.configure do |rspec|
  rspec.include CAStorage
end
