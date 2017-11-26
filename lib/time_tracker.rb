require "active_support/core_ext/time"
require "active_support/core_ext/date"

require "calendar_api/client"

require "harvest_api/client"

require "time_tracker/version"
require "time_tracker/event"

module TimeTracker
  harvest_api = HarvestApi::Client.instance
  calendar_api = CalendarApi::Client.instance
  calendar_id = 'primary'

  response = calendar_api.list_events(calendar_id,
                                      max_results: 25,
                                      single_events: true,
                                      order_by: 'startTime',
                                      time_min: Time.now.beginning_of_week.iso8601,
                                      time_max: Time.now.iso8601)

  time_events = []
  response.items.each do |event|
    time_events << TimeTracker::Event.build_from(event)
  end
end

# calendar_api = CalendarApi::Client.instance
#
# calendar_id = 'primary'
# response = calendar_api.list_events(calendar_id, max_results: 10, single_events: true, order_by: 'startTime', time_min: Time.now.iso8601)
#
# puts "Upcoming events:"
# puts "No upcoming events found" if response.items.empty?
# response.items.each do |event|
#   start = event.start.date || event.start.date_time
#   puts "- #{event.summary} (#{start})"
# end
