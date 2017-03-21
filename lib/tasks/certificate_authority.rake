namespace :certificate_authority do
  desc 'Create certificates and private keys by recept in `OpenSSL Cookbook`'
  task create_certificates: :environment do
    CreateCertificates.call
  end
end
