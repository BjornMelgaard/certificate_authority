module StorageHelpers
  delegate :load_cert, :load_private_key, to: :Storage
end

RSpec.configure do |config|
  config.include StorageHelpers
end

if defined? FactoryGirl
  FactoryGirl::SyntaxRunner.send(:include, StorageHelpers)
end

