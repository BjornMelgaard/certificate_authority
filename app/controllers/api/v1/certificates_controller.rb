class Api::V1::CertificatesController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    p params
    p request.format.symbol
    CreateFromCsr.call(params, request) do
      on(:invalid) do |errors|
        render plain: errors, status: :unprocessable_entity
      end
      on(:ok) do |certificate_chain|
        render plain: certificate_chain
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
