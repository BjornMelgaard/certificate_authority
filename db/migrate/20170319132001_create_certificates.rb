class CreateCertificates < ActiveRecord::Migration[5.0]
  def change
    create_table :certificates do |t|
      t.text    :pem,    null: false
      t.string  :serial, null: false
      t.integer :status, default: OpenSSL::OCSP::V_CERTSTATUS_GOOD
      t.integer :reason, default: OpenSSL::OCSP::REVOKED_STATUS_UNSPECIFIED
      t.datetime :revoked_at

      t.timestamps
    end
  end
end
