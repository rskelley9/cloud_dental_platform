class Appointment < ActiveRecord::Base

  belongs_to :hygienist
  belongs_to :dentist
  belongs_to :patient
  has_many :bookings
  has_many :time_slots, through: :bookings

  validates :of_type, inclusion: { in: %w(major minor closed),
    message: "%{value} is not a valid appointment type, please choose either 'major' or 'minor' " }

  # Scope

  def self.major
    where(of_type: major)
  end

  def major?
    if !self.of_type.nil?
      self.of_type == "major".downcase
    else
      false
    end
  end

  def minor?
    if !self.of_type.nil?
      self.of_type == "minor".downcase
    else
      false
    end
  end

  def major_or_closed?
    if self.minor? || self.major?
      true
    else
      false
    end
  end

  def closed?
    if !self.of_type.nil?
      self.of_type == "closed".downcase
    else
      false
    end
  end

end
