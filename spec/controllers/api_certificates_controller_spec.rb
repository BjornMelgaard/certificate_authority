require 'rails_helper'

RSpec.describe Api::V1::CertificatesController, type: :controller do
  describe '#create' do
    it 'responds with success when given name and subject' do
      expect do
        post :create, params: { csr: create(:csr).to_pem }, as: :json
      end.to change(Certificate, :count).by(1)

      expect(response).to be_success
      expect_json_types(chain: :array_of_strings)

      # validate chain
      chain = json_body[:chain].map { |cert| OpenSSL::X509::Certificate.new(cert) }
      developer_cert, subca_cert = chain
      store = OpenSSL::X509::Store.new
      store.add_cert(load_cert(:root))
      assert store.verify(developer_cert, [subca_cert])
    end
  end
end
