class Certificate < ApplicationRecord
  STATUS_GOOD    = OpenSSL::OCSP::V_CERTSTATUS_GOOD
  STATUS_REVOKED = OpenSSL::OCSP::V_CERTSTATUS_REVOKED

  REASON_KEY_COMPROMISED = OpenSSL::OCSP::REVOKED_STATUS_KEYCOMPROMISE
  REASON_UNSPECIFIED     = OpenSSL::OCSP::REVOKED_STATUS_UNSPECIFIED

  validates :pem, presence: true
  validates :serial, presence: true

  def self.create_from_certificate(cert)
    create(pem: cert.to_pem, serial: cert.serial)
  end

  def cert
    @cert ||= OpenSSL::X509::Certificate.new(pem)
  end
end
