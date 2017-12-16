require 'time_tracker/time_entry'

module TimeTracker
  class Calendar
    def calendar_api
      GoogleCalendarApi::Client.instance
    end

    def fetch_events opts = {}
      if @events
        return @events
      end
      puts "Calendar fetching events from network"

      opts[:start_time] ||= Time.now.beginning_of_week.iso8601
      opts[:end_time] ||= Time.now.iso8601
      opts[:calendar_id] ||= 'primary'

      res = calendar_api.list_events(opts[:calendar_id],
        max_results: 25,
        single_events: true,
        order_by: 'startTime',
        time_min: opts[:start_time],
        time_max: opts[:end_time])
      @events = []
      res.items.each do |event|
        @events << TimeTracker::TimeEntry.build_from(event)
      end
      @events
    end
  end
end
