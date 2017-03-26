require_relative '../support/helpers/storage_helpers'

FactoryGirl.define do
  sequence :common_name do |n|
    "Developer #{n}"
  end

  factory :certificate do
    transient do
      issuer_cert { load_cert(:subca) }
      issuer_key  { load_private_key(:subca) }
      role :developer
      name { generate :common_name }
    end

    after(:build) do |cert, evaluator|
      distinguished_name = "CN=#{evaluator.name}/O=#{evaluator.name} Org/C=UA"

      generator = CertificateFactory.new(evaluator.role)
      generator.subject = OpenSSL::X509::Name.parse distinguished_name
      generator.sign_by!(evaluator.issuer_cert, evaluator.issuer_key)
      cert.store(generator.certificate)
    end
  end
end
