class Api::V1::CertificatesController < ApplicationController
  def create
    CreateFromCsr.call(params) do
      on(:invalid) do |errors|
        render json: { errors: errors }, status: :unprocessable_entity
      end
      on(:ok) do |certificate_chain|
        render json: { chain: certificate_chain }
      end
    end
  end

  def revoke
    Revoke.call(params) do
      on(:invalid) do |errors|
        render json: { errors: errors }, status: :unprocessable_entity
      end
      on(:ok) do
        render json: {  }
      end
    end
  end
end
