Rake::Task['certificate_authority:populate_ca'].invoke

FactoryGirl.create_list :certificate, 10
