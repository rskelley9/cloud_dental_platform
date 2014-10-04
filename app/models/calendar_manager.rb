class CalendarManager
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend AppointmentTools

  attr_accessor :workday, :date, :slot_length

  validates :workday, presence: true
  validates :date, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send "#{name}=", value
    end
  end

  def persisted?
    false
  end

  # Check all available majors

  # def print_time_slots_for_major_bookings
  #   time_slots = self.workday.time_slots
  #   major_times = time_slots.select{|t| t.allow_major?}

  #   available_times = Array.new
  #   major_times.each_with_index do |t, index|
  #     slot1 = t
  #     break if t == major_times.last
  #     # Major bookings must be 4 slots long or larger
  #     slot2 = major_times[index + 1]
  #     slot3 = major_times[index + 2]
  #     slot4 = major_times[index + 3]


  #     if AppointmentTools.adjacent?(slot1, slot2) and AppointmentTools.adjacent?(slot2, slot3) and AppointmentTools.adjacent?(slot3, slot4)
  #       available_times << slot1
  #     end

  #   end

  #   # major_times.select{ |at| AppointmentTools.adjacent?(at, TimeSlot.find(at.id)) }

  #   # time_slots.where( "start_time > :start_point AND end_time < :end_point", {start_point: start, end_point: ending} )
  # end

  # def print_time_slots_for_minor_bookings

  # end

  # def print_time_slots_for_closed_bookings

  # end

  # Print all available start_times for each appointment type

  def book_slots_between(booking_first, booking_last)
    first_slot = booking_first.time_slot
    second_slot = booking_last.time_slot

    return false if AppointmentTools.adjacent?(first_slot, second_slot, @slot_length) || !booking_first.same_workday_as?(booking_last)
    return false unless booking_first.same_appointment_as?(booking_last)

    start_point = first_slot.start_time
    end_point = second_slot.end_time
    range = self.range(start_point, end_point)

    time_slots = self.return_slots_between(start_point, end_point)
    included_slots = time_slots.select{|time_slot| range.include?(time_slot.start_time)}

    # If any of the time_slots are major_or_closed or booked and the new booking is major or closed
    if CalendarManager.any_major_or_closed_or_booked_in?(included_slots) and booking_first.appointment.major_or_closed?
      puts "Major or closed appointments can't overlap other major or closed appointments, nor booked appointments."
      return false
    else
      # Book each included time_slot to same appointment as first and last booking
      CalendarManager.book_range!(booking_first, included_slots)
    end
  end

  def self.any_booked_slots_in?(arr_of_times)
    arr_of_times.any?{|t| t.booked? }
  end

  def self.any_major_or_closed_or_booked_in?(arr_of_times)
    if arr_of_times.any?{|t| t.any_major_or_closed_appointments? } || arr_of_times.any?{|t| t.booked? }
      true
    else
      false
    end
  end

  def self.all_clear_in?(arr_of_times)
    if arr_of_times.any?{|t| !t.totally_clear? }
      false
    else
      true
    end
  end

  def return_slots_between(start, ending)
    self.workday.time_slots.where( "start_time > :start_point AND end_time < :end_point", {start_point: start, end_point: ending} )
  end

  #ToDo make method more flexible
  def generate_time_slots!(length_in_minutes=15)
    # Space between start and end
    @slot_length ||= length_in_minutes

    day = self.workday.date
    hour = 9
    minute = 0
    @time_slots = Array.new

    33.times do
      beginning = TimeOfDay.parse(hour) + minute.minutes
      ending = beginning + @slot_length.minutes
      time_slot = TimeSlot.create work_day_id: self.workday.id, start_time: beginning.strftime("%I:%M %p"), end_time: ending.strftime("%I:%M %p"), date: day
      @time_slots << time_slot
      minute += @slot_length
    end
  end

  def self.book_range!(booking, time_slots)
    time_slots.each{|t| Booking.create( time_slot_id: t.id, appointment_id: booking.appointment.id, chair_id: booking.chair.id ) }
  end

  def remove_time(index=-1)
    slot = @time_slots.slice!(index)
    puts "Removed #{slot} from #{self.workday.date}"
  end

  #ToDo needs start and end time,
  def add_slot_to_end(num_minutes= 60)
    if @time_slots.empty?
      last_slot = "09:00 AM"
    else
      last_slot = Time.parse(@time_slots.last)
      new_slot = last_slot + num_minutes.minutes

      @time_slots << new_slot.strftime("%I:%M %p")
    end
  end

end