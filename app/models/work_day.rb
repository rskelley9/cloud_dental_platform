class WorkDay < ActiveRecord::Base
  extend AppointmentTools

  has_many :time_slots
  has_many :bookings, through: :time_slots

  validate :starts_before_ends

  def starts_before_ends
   start_of_day = WorkDay.tod_format(self.start_time)
   end_of_day = WorkDay.tod_format(self.end_time)

   unless start_of_day < end_of_day
    errors[:base] << "Your start time: #{self.start_time} and end time: #{self.end_time} aren't in the correct order. The work day must start at a time prior to its end time."
   end

 end

end
