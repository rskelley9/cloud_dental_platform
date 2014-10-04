class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.integer :dentist_id
      t.integer :hygienist_id
      t.integer :patient_id
      t.string :of_type
      t.boolean :patient_confirmed
      t.boolean :confirmation_sent

      t.timestamps
    end
  end
end
