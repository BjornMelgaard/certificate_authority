class CreateCertificates < ActiveRecord::Migration[5.0]
  def change
    create_table :certificates do |t|
      t.text :cert
      t.integer :serial

      t.timestamps
    end
  end
end
