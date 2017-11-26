module TimeTracker
  class Event
    attr_accessor :start_time, :end_time, :title, :description

    def self.build_from(external_event)
      if external_event.is_a? Google::Apis::CalendarV3::Event
        event = self.new
        event.title = external_event.summary
        event.start_time = external_event.start.date_time
        event.end_time = external_event.end.date_time
        event
      end
    end

    def duration
      end_time.min - start_time.min
    end
  end
end
