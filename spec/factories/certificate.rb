require_relative '../support/helpers/ca_factory_helpers'
require_relative '../support/helpers/storage_helpers'

FactoryGirl.define do
  factory :certificate do
    transient do
      issuer_cert { load_cert(:subca) }
      issuer_key  { load_private_key(:subca) }
      role :developer
    end

    after(:build) do |cert, evaluator|
      o_cert, _o_key = ca_factory_generate(
        evaluator.role,
        [evaluator.issuer_cert, evaluator.issuer_key]
      )
      cert.pem    = o_cert.to_pem
      cert.serial = o_cert.serial
    end
  end
end
