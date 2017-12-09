module TimeTracker
  class TimeEntry
    attr_accessor :start_time, :end_time, :date, :duration, :title, :description

    def self.build_from(external_event)
      if external_event.is_a? Google::Apis::CalendarV3::Event
        event = self.new
        event.title = external_event.summary
        event.start_time = Time.parse(external_event.start.date_time.iso8601)
        event.end_time = Time.parse(external_event.end.date_time.iso8601)
        event
      elsif external_event.is_a? Harvest::Resource::TimeEntry
        event = self.new
        event.title = external_event.notes
        event.date = external_event.spent_date
        event.duration = external_event.hours
        event
      end
    end

    def spent_date
      if date
        date
      else
        start_time.to_date.iso8601
      end
    end

    def hours
      if duration
        duration
      else
        (end_time - start_time) / 3600
      end
    end

    def == other
      unless other.instance_of? self.class
        return false
      end
      spent_date == other.spent_date && title == other.title && hours == other.hours
    end
  end
end
