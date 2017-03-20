namespace :certificate_authority do
  # identical to example in OpenSSL Coocbook by Ivan Ristic

  desc 'Create root certificate (ought to be distributed among end users) '\
    'and private key (please store it in secret place offline)'
  task create_root: :environment do
    CreateRoot.call
  end

  desc 'Create sub certificate, wich will be used for certificate issuance'
  task create_ca: :environment do
    CreateCA.call
  end

  desc 'Create sub certificate, wich will be used for ocsp-responce signing'
  task create_ocsp: :environment do
    CreateOcsp.call
  end
end
