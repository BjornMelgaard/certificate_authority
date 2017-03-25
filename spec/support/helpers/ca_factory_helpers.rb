module CertificateFactoryHelpers
  def ca_factory_generate(role, parent_data = nil)
    name = role.to_s.titleize
    distinguished_name = "CN=#{name}/O=#{name} Org/C=UA"

    generator = CertificateFactory.new(role)
    generator.subject = OpenSSL::X509::Name.parse distinguished_name

    if parent_data.nil?
      generator.selfsign!
    else
      generator.sign_by!(*parent_data)
    end

    [generator.certificate, generator.private_key]
  end
end

RSpec.configure do |config|
  config.include CertificateFactoryHelpers
end

if defined? FactoryGirl
  FactoryGirl::SyntaxRunner.send(:include, CertificateFactoryHelpers)
end
