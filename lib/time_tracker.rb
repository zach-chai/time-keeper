require "active_support/core_ext/time"
require "active_support/core_ext/date"

require "calendar_api/client"

require "harvest_api/client"

require "time_tracker/version"
require "time_tracker/event"


module TimeTracker
  PROJECT_ID = 12499555

  MEETING_TASK_ID = 6998455

  class << self
    def harvest_api
      HarvestApi::Client.instance
    end

    def calendar_api
      CalendarApi::Client.instance
    end

    def calendar_events opts = {}
      opts[:start_time] ||= Time.now.beginning_of_week.iso8601
      opts[:end_time] ||= Time.now.iso8601
      opts[:calendar_id] ||= 'primary'

      res = calendar_api.list_events(opts[:calendar_id],
                                    max_results: 25,
                                    single_events: true,
                                    order_by: 'startTime',
                                    time_min: opts[:start_time],
                                    time_max: opts[:end_time])
      events = []
      res.items.each do |event|
        events << TimeTracker::Event.build_from(event)
      end
      events
    end

    def harvest_events opts = {}
      opts[:start_time] ||= Time.now.beginning_of_week.iso8601
      opts[:end_time] ||= Time.now.iso8601

      res = harvest_api.time_entries.all(from: opts[:start_time],
                                        to: opts[:end_time])

      meetings = res.select {|te| te.task['id'] == MEETING_TASK_ID}
      Time.zone = 'America/Toronto'
      events = []
      meetings.each do |event|
        events << TimeTracker::Event.build_from(event)
      end
      events
    end

    def sync_events opts = {}
      untracked_events = calendar_events opts
      tracked_events = harvest_events opts
      synced_events = untracked_events.select { |e| tracked_events.include? e }
      create_events = untracked_events.reject { |e| synced_events.include? e }
      delete_events = tracked_events.reject { |e| synced_events.include? e }

      create_harvest_events create_events
      true
    end

    def create_harvest_events events
      events.each do |event|
        payload = {
          project_id: PROJECT_ID,
          task_id: MEETING_TASK_ID,
          spent_date: event.spent_date,
          hours: event.hours,
          notes: event.title
        }

        harvest_api.time_entries.create(payload)
      end
    end
  end
end

# h_events = TimeTracker.harvest_events start_time: Time.now.beginning_of_day.iso8601
#
# c_events = TimeTracker.calendar_events start_time: Time.now.beginning_of_day.iso8601
# TimeTracker.create_harvest_events events

# TimeTracker.sync_events

# puts events
