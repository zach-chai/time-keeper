require 'active_support/core_ext/time'
require 'active_support/core_ext/date'

require 'google_calendar_api/client'

require 'harvest_api/client'

require 'time_tracker/version'
require 'time_tracker/calendar'
require 'time_tracker/timesheet'


module TimeTracker
  class << self
    def sync_events opts = {}
      untracked_events = Calendar.fetch_events opts
      tracked_events = Timesheet.fetch_events opts
      synced_events = untracked_events.select { |e| tracked_events.include? e }
      create_events = untracked_events.reject { |e| synced_events.include? e }
      delete_events = tracked_events.reject { |e| synced_events.include? e }

      Timesheet.create_events create_events
      true
    end
  end
end

# h_events = TimeTracker::Timesheet.fetch_events start_time: Time.now.beginning_of_day.iso8601
# c_events = TimeTracker::Calendar.fetch_events start_time: Time.now.beginning_of_day.iso8601

# TimeTracker.sync_events

# byebug
# puts events
