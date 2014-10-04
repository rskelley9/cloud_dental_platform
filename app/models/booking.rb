class Booking < ActiveRecord::Base

  belongs_to :time_slot
  belongs_to :chair
  belongs_to :appointment

  # One appointment can't be made twice for the same time_slot
  validates_uniqueness_of :appointment_id, { scope: :time_slot_id, message: "The same appointment can't be made twice for the same time slot." }

  # Two bookings can't have the same chair if they have the same time
  validates_uniqueness_of :chair_id, { scope: :time_slot_id, message: "Multiple appointments can't be booked for the same chair, at the same time." }

  # Major appointments can't be booked simultaneously with any other appointments
  # Minor appointments can be booked with other minor appointments for the same time slots
  validate :validate_available

  # Two time_slots can have the same appointment_id only if they're adjacent

  # A time_slot can have a maximum of 1 booking for appointment.of_type = "major"


  def validate_available
    appointment = self.appointment
    time_slot = self.time_slot

    if appointment.major?
      unless time_slot.allow_major?
        errors[:base] << "Time slot has #{self.time_slot.appointments.count} #{self.time_slot.appointments.of_type} appointment already. It needs to have 0 bookings before a 'major' appointment can be booked."
      end
    elsif appointment.minor?
      if time_slot.booked?
        errors[:base] << "Time already booked. Time slot needs to have 0 or 1 bookings before an appointment of type 'minor' can be booked."
      end
    elsif appointment.closed?
      unless time_slot.totally_clear?
        errors[:base] << "Time has an appointment booked already. You may only close empty slots."
      end
    end
  end


  def same_appointment_as?(booking)
    self.appointment.id == booking.appointment.id
  end

  def same_workday_as?(booking)
    self.time_slot.workday.id == booking.time_slot.workday.id
  end


end
