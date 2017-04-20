require Rails.root.join('lib', 'storage')

module OcspCertAndKey
  extend ActiveSupport::Concern

  included do
    def self.ocsp_cert
      @ocsp_cert ||= Storage.load_cert(:ocsp)
    end

    def self.ocsp_key
      @ocsp_key ||= Storage.load_private_key(:ocsp)
    end

    delegate :ocsp_cert, :ocsp_key, to: :class
  end
end
