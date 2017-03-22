require 'rails_helper'

RSpec.describe Api::V1::CertificatesController, type: :controller do
  describe '#create' do
    let(:csr) { create(:csr).to_pem }

    it 'responds with success when given name and subject' do
      expect do
        post :create, params: { csr: csr }, as: :json
      end.to chenge(Certificate.count).by(1)

      expect(response).to be_success
      expect(response.response_code).to eq(201)
    end
  end
end
