require 'date'
require 'csv'

#date_from  = Date.parse('2017-01-01')
#date_to    = Date.parse('2017-12-31')
#puts (date_from..date_to).map(&:to_s)
def transform_to_date(date)
  year = date[0..3]
  month = date[4..5]
  day = date[6..7]
  return Date.parse("#{year}-#{month}-#{day}")
end

data_set = CSV.read('Bodea_Choice_based_Revenue_Management_Data_Set_Hotel_1.csv')

grouped_by_room_type = Hash.new
first = true
data_set.each {|row|
  if first
    first = false
    next
  end
  booking_date = row[4]
  checkin_date = row[5]
  checkout_date = row[6]
  room_type = row[15]
  to_add = { :booking_date => transform_to_date(booking_date), :checkin_date => transform_to_date(checkin_date), :checkout_date => transform_to_date(checkout_date), :is_dead => false}
  if grouped_by_room_type.key?(room_type)
    grouped_by_room_type[room_type].push(to_add)
  else
    grouped_by_room_type[room_type] = [to_add]
  end
}
grouped_by_room_type.each { |room_type, value|
  puts room_type
}