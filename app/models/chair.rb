class Chair < ActiveRecord::Base
  has_many :bookings
  has_many :time_slots, through: :bookings
  belongs_to :office
end
