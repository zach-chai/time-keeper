require 'time_keeper/time_entry'

module TimeKeeper
  class Calendar
    def calendar_api
      GoogleCalendarApi::Client.instance
    end

    def initialize opts = {}
      @opts = opts
      @opts[:calendar_id] ||= 'primary'
    end

    def fetch_events
      if @events
        return @events
      end
      puts "Calendar fetching events via network"

      @events = []
      week_dates = (Time.parse(@opts[:start_time]).to_date .. Time.parse(@opts[:end_time]).to_date).to_a

      res = calendar_api.list_events(@opts[:calendar_id],
        max_results: 25,
        single_events: true,
        order_by: 'startTime',
        time_min: @opts[:start_time],
        time_max: @opts[:end_time])

      res.items.each do |event|
        start_date = event.start.date || event.start.date_time.to_date.iso8601
        end_date = event.end.date || event.end.date_time.to_date.iso8601
        event_range = (Date.parse(start_date) .. Date.parse(end_date)).to_a

        if event_range.length > 1
          (week_dates & event_range[0...-1]).each do |date|
            @events << TimeKeeper::TimeEntry.build_from(event, date: date)
          end
        else
          @events << TimeKeeper::TimeEntry.build_from(event)
        end
      end
      @events
    end
  end
end
