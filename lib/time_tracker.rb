require 'active_support/core_ext/time'
require 'active_support/core_ext/date'

require 'google_calendar_api/client'

require 'harvest_api/client'

require 'time_tracker/version'
require 'time_tracker/calendar'
require 'time_tracker/timesheet'


module TimeTracker
  class Main
    def initialize opts = {}
      @opts = opts
      @timesheet = Timesheet.new
      @calendar = Calendar.new
    end

    def sync_events
      @timesheet.delete_tasks unknown_events
      @timesheet.create_tasks Timesheet::ENG_OVERHEAD_TASK_ID, unsynced_events
    end

    private

    def untracked_events
      @calendar.fetch_events @opts
    end

    def tracked_events
      @timesheet.fetch_tasks [Timesheet::ENG_OVERHEAD_TASK_ID, Timesheet::NON_ENG_OVERHEAD_TASK_ID],
                             @opts
    end

    def synced_events
      untracked_events.select { |e| tracked_events.include? e }
    end

    def unsynced_events
      untracked_events.reject { |e| synced_events.include? e }
    end

    def unknown_events
      tracked_events.reject { |e| synced_events.include? e }
    end
  end
end

# time_tracker = TimeTracker::Main.new
#                 start_time: Time.now.beginning_of_day.iso8601

# tracked_events = time_tracker.send(:tracked_events)
# untracked_events = time_tracker.send(:untracked_events)
# synced_events = time_tracker.send(:synced_events)
# unsynced_events = time_tracker.send(:unsynced_events)
# unknown_events = time_tracker.send(:unknown_events)

# time_tracker.sync_events

# byebug
# puts events
