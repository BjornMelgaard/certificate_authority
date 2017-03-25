FactoryGirl.define do
  factory :csr, class: OpenSSL::X509::Request do
    skip_create

    version 0
    subject { OpenSSL::X509::Name.parse 'CN=Maksim Developer/O=Maksim Org/C=UA' }

    transient do
      keypair { OpenSSL::PKey::RSA.new 2048 }
      digest  { OpenSSL::Digest::SHA256.new }
    end

    after(:build) do |csr, evaluator|
      csr.public_key = evaluator.keypair.public_key
      csr.sign evaluator.keypair, evaluator.digest
    end
  end
end
