module SubcaData
  extend ActiveSupport::Concern

  included do
    helper_method :subca_cert, :subca_key
  end

  def subca_cert
    @subca_cert ||= Storage.load_cert(:subca)
  end

  def subca_key
    @subca_key ||= Storage.load_private_key(:subca)
  end
end
