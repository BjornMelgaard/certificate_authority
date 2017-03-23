class Api::V1::CertificatesController < ApplicationController
  def create
    CreateFromCsr.call(params) do
      on(:invalid) do |errors|
        render json: { errors: errors }, status: :unprocessable_entity
      end
      on(:ok) do |id, pem|
        render json: { id: id, pem: pem }
      end
    end
  end
end
