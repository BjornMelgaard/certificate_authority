class Revoke < Rectify::Command
  def initialize(params)
    @params = params
  end

  def call
    set_certificate
    return broadcast(:invalid, ['Invalid certificate']) unless @certificate
    return broadcast(:invalid, ['Already revoked']) if @certificate.revoked?
    @certificate.revoke

    broadcast(:ok, @certificate)
  end

  private

  def set_certificate
    @certificate = Certificate.find_by(serial: params[:serial])
  end
end
