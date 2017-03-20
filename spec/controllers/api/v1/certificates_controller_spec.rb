require 'rails_helper'

RSpec.describe Api::V1::CertificatesController, type: :controller do
  describe '#create' do
    it 'responds with success when given name and subject' do
      params = { name: 'My CA', subject: '/CN=My Sweet CA' }
      post :create, params: params, as: :json

      expect(response).to be_success
      expect(response.response_code).to eq(201)
    end

    # it 'responds with an error when no name' do
    #   params = { name: 'My CA' }
    #   post :create, params: params, as: :json

    #   expect(response).not_to be_success
    #   expect(response.response_code).to eq(400)
    # end
  end

  describe '#create_from_csr' do
  end
end
