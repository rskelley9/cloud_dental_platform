
# Uncomment to run Sprig seed files
# path = Rails.root.join('db', 'seeds', "#{Rails.env}.rb")
# load path if File.exist?(path)
# puts "Running Sprig seed files

puts "Running db/seeds.rb"

puts "Seeding an office into database."

Office.create! do |office|
  office.name = "William Ryan DMD, LLC"
  office.address = "10 Hinsdale Avenue"
  office.zip = "06098"
  office.city = "Winsted"
  office.phone = "8603794382"
  office.fax = "8607384720"
end

puts "Seeding 1 dentist into database."

Dentist.create! do |dentist|
  dentist.first_name = "William"
  dentist.last_name = "Ryan"
end

puts "Seeding 2 hygienists into database."

Hygienist.create! do |h|
  h.first_name = Faker::Name.first_name
  h.last_name = Faker::Name.last_name
end

puts "Seeding chairs into database."

["room one", "room two"].each do |room|
  Chair.find_or_create_by(room: room) do |chair|
    chair.booked = false
  end
end

puts "Seeding AdminUser account."

unless AdminUser.any?
  AdminUser.create! do |a|
    a.email = ENV["admin_email_development"]
    a.password = ENV["admin_password_development"]
  end
end


pwid_values = (1..10).to_a
patient_birthday = 26.years.ago.strftime('%m/%d/%Y')
puts "Seeding first patient, born on #{patient_birthday}."

if Patient.find_by_email(ENV["patient_email_development"]).nil?
  Patient.create! do |p|
    p.first_name = "Ryan"
    p.last_name = "Kelley"
    p.email = ENV["patient_email_development"]
    p.password = ENV["patient_password_development"]
    p.birthday = patient_birthday
    p.new_patient = false
    p.phone = Faker::PhoneNumber.cell_phone
    p.address = Faker::Address.street_address
    p.zip = Faker::Address.zip
    p.pwid = pwid_values.slice(0)
    p.city = Faker::Address.city
  end
end

puts "Seeding 10 more patients."
rand_birthday = rand(19..50).years.ago.strftime('%m/%d/%Y')

10.times do
  Patient.create! do |p|
    p.first_name = Faker::Name.first_name
    p.last_name = Faker::Name.last_name
    p.email = Faker::Internet.email
    p.password = "password1"
    p.birthday = rand_birthday
    p.new_patient = [true,false][rand 2]
    p.phone = Faker::PhoneNumber.cell_phone
    p.address = Faker::Address.street_address
    p.zip = Faker::Address.zip
    p.pwid = pwid_values.slice!(0)
    p.city = Faker::Address.city
  end
end

puts "Seeding Workdays."

day_numbers = (1..5).to_a
5.times do
  start_time = WorkDay.time_slot_format(9)
  end_time = WorkDay.time_slot_format([17,18][rand(2)])
  rand_date = Date.today + day_numbers.slice!(0)
  WorkDay.create(start_time: start_time, end_time: end_time, date: rand_date )
end

puts "Generating Time Slots for each WorkDay"

workdays = WorkDay.all
workday_number = 1

workdays.each do |workday|
  calendar_manager = CalendarManager.new(workday: workday, date: workday.date)
  puts "Seeding time slots for workday number #{workday_number}"
  workday_number += 1
  calendar_manager.generate_time_slots!
end

patients = Patient.all
of_types_list = ["major", "minor"]

puts "Seeding one appointment per workday"
workday_number = 1
5.times do

  Appointment.create! do |a|
    a.dentist_id = Dentist.first.id
    a.hygienist_id = Hygienist.first.id
    a.patient_id = patients.slice(1 + workday_number).id
    a.of_type = of_types_list[rand(2)]
    a.patient_confirmed = false
    a.confirmation_sent = false
  end
  workday_number += 1
end

puts "Seeding one major appointment on last workday"
Appointment.create!( :dentist_id => Dentist.first.id, :hygienist_id => Hygienist.first.id, :patient_id => Patient.find_by_email(ENV["patient_email_development"]).id, :of_type => "major", :patient_confirmed => false, :confirmation_sent => false )


