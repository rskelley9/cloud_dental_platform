class TimeSlot < ActiveRecord::Base
  extend AppointmentTools
  # each appointment has many time_slots and each time_slot appears in many appointments

  # validate :availability, unless: "appointments.nil?"

  has_many :bookings
  has_many :appointments, through: :bookings
  belongs_to :work_day

  def booked?
    if self.appointments.count == 0
      self.update(booked: false)
      return false
    elsif self.appointments.count == 2
      self.update(booked: true)
      return true
    elsif self.appointments.count == 1 and self.appointments.last.of_type == "minor"
      self.update(booked: false)
      return false
    else
      self.update(booked: true)
      return true
    end
  end

  def totally_clear?
    self.appointments.count == 0
  end

  def allow_major?
    if self.appointments.count == 0
      true
    elsif self.appointments.count == 1 && self.appointments.where(of_type: "major").empty?
      true
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
