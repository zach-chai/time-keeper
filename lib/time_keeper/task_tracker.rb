require 'time_keeper/time_entry'

module TimeKeeper
  class TaskTracker
    def tracker_api
      PivotalApi::Client.instance
    end

    def initialize opts = {}
      @opts = opts
      @opts[:start_time] ||= Time.current.beginning_of_week.iso8601
      @opts[:end_time] ||= Time.current.iso8601
    end

    def tasks_delivered(date = nil)
      activity('delivered', date).map(&:primary_resources).flatten
    end

    def activity(highlight, date = nil)
      filter_activity('story_update_activity', highlight, date)
    end

    private

    def filter_activity(kind, highlight, date = nil)
      filtered = my_activity.select {|a| a.kind == kind && a.highlight == highlight }
      if date
        filtered.select {|a| a.occurred_at.to_date == date}
      else
        filtered
      end
    end

    def my_activity
      @activity ||= tracker_api.activity(occurred_after: @opts[:start_time])
    end

  end
end
