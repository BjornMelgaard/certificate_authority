class Api::V1::CertificatesController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    CreateFromCsr.call(params) do
      on(:invalid) do |errors|
        render json: { errors: errors }, status: :unprocessable_entity
      end
      on(:ok) do |certificate|
        render json: {
          certificate: certificate.cert.to_pem,
          serial:      certificate.serial,
          created_at:  certificate.created_at.strftime('%d/%m/%Y at %H:%M'),
          common_name: certificate.cert.subject.common_name
        }
      end
    end
  end

  def revoke
    Revoke.call(params) do
      on(:invalid) do |errors|
        render json: { errors: errors }, status: :unprocessable_entity
      end
      on(:ok) do |cert|
        render json: cert.slice(:status, :reason).merge(serial: cert.serial.to_s)
      end
    end
  end
end
