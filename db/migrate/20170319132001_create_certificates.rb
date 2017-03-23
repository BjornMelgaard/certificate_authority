class CreateCertificates < ActiveRecord::Migration[5.0]
  def change
    create_table :certificates do |t|
      t.text :pem
      t.string :serial

      t.timestamps
    end
  end
end
