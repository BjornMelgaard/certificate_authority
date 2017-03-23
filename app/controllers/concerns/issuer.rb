module Issuer
  extend ActiveSupport::Concern

  included do
    helper_method :issuer
  end

  def issuer
    @issuer ||= begin
      role = :subca
      cert = Storage.load_cert(role)
      private_key = Storage.load_private_key(role)
      CA::Certificate.from_existing cert, private_key
    end
  end
end
