require 'rails_helper'

RSpec.describe Api::V1::CertificatesController, type: :controller do
  describe '#create' do
    it 'responds with success when given name and subject' do
      expect do
        post_text :create, create(:csr).to_pem
      end.to change(Certificate, :count).by(1)

      expect(response).to be_success

      # validate chain
      chain = parse_chain(response.body)
              .map { |cert| OpenSSL::X509::Certificate.new(cert) }
      developer_cert, subca_cert = chain
      store = OpenSSL::X509::Store.new
      store.add_cert(load_cert(:root))
      assert store.verify(developer_cert, [subca_cert])
    end

    it 'respond with invalid if invalid format' do
      post :create, params: { csr: 'asdfasf' }, as: :json
      expect(response).not_to be_success
      expect(response.body).to eq 'Invalid format'
    end
  end

  describe '#revoke' do
    it 'revoke valid cert' do
      cert = create :certificate
      post :revoke, params: { serial: cert.serial }, as: :json

      cert.reload

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
