class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.integer :time_slot_id
      t.integer :appointment_id
      t.integer :chair_id

      t.timestamps
    end
  end
end
