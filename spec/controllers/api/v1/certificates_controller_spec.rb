require 'rails_helper'

RSpec.describe Api::V1::CertificatesController, type: :controller do
  describe '#create' do
    it 'responds with success when given name and subject' do
      expect do
        post :create, params: { csr: create(:csr).to_pem }, as: :json
      end.to change(Certificate, :count).by(1)

      expect(response).to be_success
      expect_json_types(pem: :string, serial: :string)
      # pem = json_body[:pem]
      # cert = OpenSSL::X509::Certificate.new pem
      # subca_cert = load_authority_cert_by_http(cert)
      # root_cert = load_authority_cert_by_http(subca_cert)
      # expect(cert.verify(root_cert.public_key)).to eq true
    end
  end
end
