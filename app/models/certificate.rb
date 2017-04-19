class Certificate < ApplicationRecord
  validates :pem,
            length: { minimum: 1000, maximum: 3000 },
            presence: true

  validates :serial,
            format: { with: /\d+/, message: 'only numbers' },
            presence: true

  def self.create_from_certificate(certificate)
    create(pem: certificate.to_pem, serial: certificate.serial.to_i)
  end

  def store(certificate)
    self.pem    = certificate.to_pem
    self.serial = certificate.serial.to_i
    save!
  end

  def cert
    @cert ||= OpenSSL::X509::Certificate.new(pem)
  end

  def revoke
    update(
      status:     OpenSSL::OCSP::V_CERTSTATUS_REVOKED,
      reason:     OpenSSL::OCSP::REVOKED_STATUS_UNSPECIFIED,
      revoked_at: Time.zone.now
    )
  end

  def revoked?
    revoked_at.present?
  end
end
