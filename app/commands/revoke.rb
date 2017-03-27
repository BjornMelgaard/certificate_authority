class Revoke < Rectify::Command
  def initialize(params)
    @params = params
  end

  def call
    return broadcast(:invalid, ['Invalid certificate']) unless set_certificate
    return broadcast(:invalid, ['Already revoked']) if @certificate.revoked?
    revoke

    broadcast(:ok, @certificate)
  end

  private

  def set_certificate
    @certificate = Certificate.find_by(serial: params[:serial])
  end

  def revoke
    @certificate.update(
      status: Certificate::STATUS_REVOKED,
      reason: Certificate::REVOKED_STATUS_UNSPECIFIED
    )
  end
end
