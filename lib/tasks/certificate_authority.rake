namespace :certificate_authority do
  desc 'Create certificates and private keys by recept in `OpenSSL Cookbook`'
  task populate_ca: :environment do
    PopulateCA.call
  end
end
