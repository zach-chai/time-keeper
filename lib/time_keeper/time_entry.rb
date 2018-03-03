module TimeKeeper
  class TimeEntry
    attr_accessor :id, :task_id, :start_time, :end_time, :date, :duration, :title, :description

    HOLIDAY_TITLE = 'Holiday'.freeze
    VACATION_TITLE = 'Vacation'.freeze
    SICK_TITLE = 'Sick'.freeze
    DEVELOPMENT_TITLE = 'Research and Development'.freeze

    def self.build_from(external_event, opts = {})
      if external_event.is_a? Google::Apis::CalendarV3::Event
        event = self.new
        event.title = external_event.summary
        if opts[:date]
          event.date = opts[:date].iso8601
          event.duration = 8
        else
          event.start_time = Time.parse(external_event.start.date_time.iso8601)
          event.end_time = Time.parse(external_event.end.date_time.iso8601)
        end
        event
      elsif external_event.is_a? Harvest::Resource::TimeEntry
        event = self.new
        event.id =  external_event.id
        event.task_id = external_event.task['id']
        event.title = external_event.notes
        event.date = external_event.spent_date
        event.duration = external_event.hours
        event
      end
    end

    def initialize props = {}
      @id = props[:id]
      @task_id = props[:task_id]
      @start_time = props[:start_time]
      @end_time = props[:end_time]
      @date = props[:date]
      @duration = props[:duration]
      @title = props[:title]
      @description = props[:description]
    end

    def full_description
      if task_id == 6908966
        title + description
      else
        title
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
      actual = if duration
                 duration
               else
                 (end_time - start_time) / 3600
               end
      actual.round(2)
    end

    def == other
      unless other.instance_of? self.class
        return false
      end
      spent_date == other.spent_date && (title == other.title || (task_id == other.task_id && task_id == 6908966)) && hours == other.hours
    end
  end
end
