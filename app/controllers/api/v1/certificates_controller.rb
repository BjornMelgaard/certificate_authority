class Api::V1::CertificatesController < ApplicationController
  def create
    CreateFromCsr.call(params) do
      on(:invalid) do |errors|
        render json: { errors: errors }, status: :unprocessable_entity
      end
      on(:ok) do |p7chain, certificate|
        render json: { pem: p7chain.to_pem, serial: certificate.serial }
      end
    end
  end
end
