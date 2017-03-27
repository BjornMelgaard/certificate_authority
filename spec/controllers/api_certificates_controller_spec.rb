require 'rails_helper'

RSpec.describe Api::V1::CertificatesController, type: :controller do
  describe '#create' do
    it 'responds with success when given name and subject' do
      expect do
        post :create, params: { csr: create(:csr).to_pem }, as: :json
      end.to change(Certificate, :count).by(1)

      expect(response).to be_success
      expect_json_types(certificate: :string, serial: :string)

      # validate chain
      developer_cert = OpenSSL::X509::Certificate.new(json_body[:certificate])
      store = OpenSSL::X509::Store.new
      store.add_cert load_cert(:root)
      assert store.verify(developer_cert, [load_cert(:subca)])
    end
  end

  describe '#revoke' do
    it 'revoke valid cert' do
      cert = create :certificate
      post :revoke, params: { serial: cert.serial }, as: :json

      cert.reload

      expect_json_types(serial: :string, status: :int, reason: :int)

      expect(cert.status).to eq Certificate::STATUS_REVOKED
      expect(cert.reason).to eq Certificate::REVOKED_STATUS_UNSPECIFIED
    end

    it 'error if already revoked' do
      cert = create :certificate,
                    status: Certificate::STATUS_REVOKED

      expect do
        post :revoke, params: { serial: cert.serial }, as: :json
      end.not_to change { [cert.status, cert.reason] }

      expect(response).not_to be_success
      expect_json_types(errors: :array_of_strings)
    end

    it 'error if invalid serial' do
      post :revoke, params: { serial: 'asfd' }, as: :json

      expect(response).not_to be_success
      expect_json_types(errors: :array_of_strings)
    end
  end
end
