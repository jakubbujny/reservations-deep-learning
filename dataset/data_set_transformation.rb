require 'date'
require 'csv'


def transform_to_date(date)
  year = date[0..3]
  month = date[4..5]
  day = date[6..7]
  return "#{year}-#{month}-#{day}"
end

def create_days_stream_and_merge_alive_terms(alive_terms, room_type)
  date_from = Date.parse('2007-03-12')
  date_to = Date.parse('2007-04-15')
  days_stream = (date_from..date_to).map(&:to_s)
  return merge_terms(days_stream, alive_terms, room_type)
end

def merge_terms(days_stream, alive_terms, room_type)
  alive_stream = []
  reservation_length = {}
  time_from_booking = {}
  alive_terms.each {|alive_term|
    date_from = Date.parse(alive_term[:checkin_date])
    date_to = Date.parse(alive_term[:checkout_date])
    days = (date_from..date_to).map(&:to_s)
    alive_stream.concat days
    days.each {|day|
      reservation_length[day] = days.length
      time_from_booking[day] = Date.parse(alive_term[:checkin_date]).mjd - Date.parse(alive_term[:booking_date]).mjd
    }
  }
  dead_counter = 0
  reserved_length = 0
  return days_stream.map {|day|
    {:date => day, :is_dead => alive_stream.include?(day) == false, :room_type => room_type}
  }.map {|day|
    if day[:is_dead] == true
      dead_counter += 1
      reserved_length = 0
    else
      dead_counter = 0
      reserved_length += 1
    end
    day[:dead_counter] = dead_counter
    day[:reserved_length] = reserved_length
    day
  }.map{ |day|
    if day[:is_dead] == false
      day[:reservation_length] = reservation_length[day[:date]]
      day[:time_from_booking] = time_from_booking[day[:date]]
    else
      day[:reservation_length] = 0
      day[:time_from_booking] = 0
    end
    day
  }
end


#data_set = CSV.read('Bodea_Choice_based_Revenue_Management_Data_Set_Hotel_1.csv')
data_set_name = 'dataset4.csv'
data_set = CSV.read(data_set_name)
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
  to_add = {:booking_date => transform_to_date(booking_date), :checkin_date => transform_to_date(checkin_date), :checkout_date => transform_to_date(checkout_date)}
  if grouped_by_room_type.key?(room_type)
    grouped_by_room_type[room_type].push(to_add)
  else
    grouped_by_room_type[room_type] = [to_add]
  end
}
is_dead_classified = grouped_by_room_type.map {|room_type, alive_terms|
  create_days_stream_and_merge_alive_terms(alive_terms, room_type)
}.flatten

serialize = is_dead_classified.reduce("room_type,week_number,is_dead,day_in_week,dead_counter,reservation_length,time_from_booking,reserved_length\n") {|reduce, flat|
  reduce += "#{flat[:room_type].dup.sub!(/([0-9 ]+)(Smoking|Non-Smoking)/, '')},#{Date.parse(flat[:date]).cweek},#{flat[:is_dead]},#{Date.parse(flat[:date]).wday},#{flat[:dead_counter]},#{flat[:reservation_length]},#{flat[:time_from_booking]},#{flat[:reserved_length]}\n"
}
File.open("ML_"+data_set_name, 'w') { |file| file.write(serialize) }

