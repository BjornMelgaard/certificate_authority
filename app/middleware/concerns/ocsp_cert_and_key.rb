require Rails.root.join('lib', 'storage')

module OcspCertAndKey
  extend ActiveSupport::Concern

  included do
    delegate :ocsp_cert, :ocsp_key, to: :class
  end

  module ClassMethods
    def ocsp_cert
      @ocsp_cert ||= Storage.load_cert(:ocsp)
    end

    def ocsp_key
      @ocsp_key ||= Storage.load_private_key(:ocsp)
    end
  end
end
