class CreateCertificates < ActiveRecord::Migration[5.0]
  def change
    create_table :certificates do |t|
      t.text    :pem,    null: false
      t.string  :serial, null: false
      t.integer :status
      t.integer :reason

      t.timestamps
    end
  end
end
