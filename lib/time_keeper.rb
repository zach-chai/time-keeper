require 'active_support/core_ext/time'
require 'active_support/core_ext/date'

require 'google_calendar_api/client'
require 'harvest_api/client'
require 'pivotal_api/client'

require 'time_keeper/version'
require 'time_keeper/calendar'
require 'time_keeper/timesheet'
require 'time_keeper/task_tracker'


module TimeKeeper
  class Main
    def initialize opts = {}
      @opts = opts
      @opts[:day_hours] = 8
      @opts[:start_time] ||= Time.current.beginning_of_week.iso8601
      @opts[:end_time] ||= Time.current.iso8601
      @timesheet = Timesheet.new opts
      @calendar = Calendar.new opts
      Time.zone = 'America/Toronto'
    end

    def sync
      grouped = untracked_events.group_by {|e| e.spent_date}
      grouped.each do |date, events|
        titles = events.map(&:title)
        if titles.include?(title = TimeEntry::HOLIDAY_TITLE)
          sync_task date, Timesheet::HOLIDAY_TASK_ID, title, @opts[:day_hours]
        elsif titles.include?(title = TimeEntry::VACATION_TITLE)
          sync_task date, Timesheet::VACATION_TASK_ID, title, @opts[:day_hours]
        elsif titles.include?(title = TimeEntry::SICK_TITLE)
          sync_task date, Timesheet::SICK_LEAVE_TASK_ID, title, @opts[:day_hours]
        else
          sync_events date, events

          sync_task(date,
                    Timesheet::DEVELOPMENT_TASK_ID,
                    TimeEntry::DEVELOPMENT_TITLE,
                    @opts[:day_hours] - events.map(&:hours).reduce(0, :+))
        end
      end
      true
    end

    def sync_task date, task_id, title, duration
      tasks = tracked_entries date

      time_entry = TimeEntry.new(
                     task_id: task_id,
                     date: date,
                     duration: duration,
                     title: title
                   )
      invalid_tasks = tasks.select do|t|
                        t.title == title && t.task_id == task_id && t.hours != duration
                      end

      @timesheet.delete_tasks(invalid_tasks)
      unless tasks.include?(time_entry)
        @timesheet.create_tasks [time_entry]
      end
    end

    def sync_events date, events
      synced_entries = synced_events date, events
      unknown_events = tracked_events(date).reject { |e| synced_entries.include? e }
      unsynced_events = events.reject { |e| synced_entries.include? e }
      unsynced_events.each {|ue| ue.task_id = Timesheet::ENG_OVERHEAD_TASK_ID}

      @timesheet.delete_tasks(unknown_events)
      @timesheet.create_tasks(unsynced_events)
    end

    private

    def tracked_entries date, tasks = Timesheet::ALL_TASK_IDS
      @timesheet.fetch_tasks tasks, date
    end

    def untracked_events
      @calendar.fetch_events
    end

    def synced_events date, events
      events.select do |event|
        tracked_entries(
          date,
          [Timesheet::ENG_OVERHEAD_TASK_ID, Timesheet::NON_ENG_OVERHEAD_TASK_ID]
        ).include? event
      end
    end

    def tracked_events date
      tracked_entries date, [Timesheet::ENG_OVERHEAD_TASK_ID, Timesheet::NON_ENG_OVERHEAD_TASK_ID]
    end
  end
end
