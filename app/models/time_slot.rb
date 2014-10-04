class TimeSlot < ActiveRecord::Base
  extend AppointmentTools

  # Each appointment can cover multiple time_slots and each time_slot can include many appointments
  has_many :bookings
  has_many :appointments, through: :bookings
  has_many :chairs, through: :bookings
  belongs_to :work_day

  # Before saving to database, make sure to update booked attribute
  # before_save :update_booked

  # WIP: DEBUG: error in update_booked, can't update database to make it booked
  # def update_booked
  #   if self.booked?
  #     self.booked = true
  #     self.save!
  #   else
  #     self.booked = false
  #     self.save!
  #   end
  # end

  # Major or minor appointments can be booked concurrently with a max of 2 appointments.
  def booked?
    if self.appointments.count == 0
      return false # It is not booked.
    elsif self.appointments.count == 2
      return true # It is booked.
    elsif self.appointments.count == 1 and !self.appointments.last.closed?
      return false # It is not booked.
    else
      return true # It is booked.
    end
  end


  def totally_clear?
    self.appointments.count == 0
  end

  def any_major_or_closed_appointments?
    if self.appointments.count > 0
      self.appointments.any?{|a| a.major_or_closed? }
    else
      false
    end
  end

  def allow_major?
    if self.appointments.count == 0
      true
    elsif self.appointments.count == 1 && !self.appointments.where(of_type: "minor").empty?
      true # If there's 1 appointment and that appointment is minor
    else
      false
    end
  end

  def duration_in(unit= "hours")
    @range ||= self.range
    duration = @range.duration / 1.try(unit).to_f
    case unit.downcase
    when "minutes"
      duration * 60
    when "seconds"
      duration * 60
    else
      duration
    end
  end

  # def same_chair
  #   filled_chairs_at_time = self.appointments.map(&:chair)
  # end

  # def availability
  #   if self.chairs.count == 0
  #     self.booked = false
  #   elsif self.chairs.count == 2
  #     self.booked = true
  #   elsif self.chairs.count == 1 and self.appointment.of_type == "cleaning"
  #     self.booked = false
  #   else
  #     self.booked = true
  #   end
  # end

  #  def bookable?(*time_slots, workday)

  # end

end
