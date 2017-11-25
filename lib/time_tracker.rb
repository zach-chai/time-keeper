require "time_tracker/version"

require "calendar_api/client"

module TimeTracker
  calendar_api = CalendarApi::Client.instance

  calendar_id = 'primary'
  response = calendar_api.list_events(calendar_id,
                                 max_results: 10,
                                 single_events: true,
                                 order_by: 'startTime',
                                 time_min: Time.now.iso8601)

  puts "Upcoming events:"
  puts "No upcoming events found" if response.items.empty?
  response.items.each do |event|
    start = event.start.date || event.start.date_time
    puts "- #{event.summary} (#{start})"
  end
end
