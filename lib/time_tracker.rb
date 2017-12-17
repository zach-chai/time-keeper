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

    def sync
      grouped = untracked_events.group_by {|e| e.spent_date}
      grouped.each do |date, events|
        titles = events.map(&:title)
        if titles.include?(title = TimeEntry::HOLIDAY_TITLE)
          all_day_event date, Timesheet::HOLIDAY_TASK_ID, title
        elsif titles.include?(title = TimeEntry::VACATION_TITLE)
          all_day_event date, Timesheet::VACATION_TASK_ID, title
        elsif titles.include?(title = TimeEntry::SICK_TITLE)
          all_day_event date, Timesheet::SICK_LEAVE_TASK_ID, title
        else
          synced_tasks = synced_events date, events
          unknown_events = tracked_events(date).reject { |e| synced_tasks.include? e }
          unsynced_events = events.reject { |e| synced_tasks.include? e }
          unsynced_events.each {|ue| ue.task_id = Timesheet::ENG_OVERHEAD_TASK_ID}

          @timesheet.delete_tasks(unknown_events)
          @timesheet.create_tasks(unsynced_events)
        end
      end
    end

    def all_day_event date, task_id, title
      tasks = tracked_tasks date

      time_entry = TimeEntry.new(
                     task_id: task_id,
                     date: date,
                     duration: 8,
                     title: title
                   )

      unless tasks.include?(time_entry)
        @timesheet.create_tasks [time_entry]
      end
    end

    private

    def tracked_tasks date, tasks = Timesheet::ALL_TASK_IDS
      @timesheet.fetch_tasks tasks, date, @opts
    end

    def untracked_events
      @calendar.fetch_events @opts
    end

    def synced_events date, events
      events.select do |event|
        tracked_tasks(
          date,
          [Timesheet::ENG_OVERHEAD_TASK_ID, Timesheet::NON_ENG_OVERHEAD_TASK_ID]
        ).include? event
      end
    end

    def tracked_events date
      tracked_tasks date, [Timesheet::ENG_OVERHEAD_TASK_ID, Timesheet::NON_ENG_OVERHEAD_TASK_ID]
    end
  end
end

time_tracker = TimeTracker::Main.new
#                 start_time: Time.now.beginning_of_day.iso8601

# time_tracker.sync
#
# byebug
# puts events
