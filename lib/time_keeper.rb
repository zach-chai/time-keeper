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
      @opts[:default_working_days] ||= %w(monday tuesday wednesday thursday friday)
      @timesheet = Timesheet.new opts
      @calendar = Calendar.new opts
      @task_tracker = TaskTracker.new opts
      Time.zone = 'America/Toronto'
    end

    def sync
      default_event_dates = build_default_working_range
      grouped_events = default_event_dates.merge(untracked_events.group_by(&:spent_date))
      grouped_events.each do |date, events|
        titles = events.map(&:title)
        if titles.include?(title = TimeEntry::HOLIDAY_TITLE)
          sync_entry date, Timesheet::HOLIDAY_TASK_ID, title, @opts[:day_hours]
        elsif titles.include?(title = TimeEntry::VACATION_TITLE)
          sync_entry date, Timesheet::VACATION_TASK_ID, title, @opts[:day_hours]
        elsif titles.include?(title = TimeEntry::SICK_TITLE)
          sync_entry date, Timesheet::SICK_LEAVE_TASK_ID, title, @opts[:day_hours]
        else
          sync_events date, events

          sync_dev_entry(date, @opts[:day_hours] - events.map(&:hours).reduce(0, :+))
        end
      end
      true
    end

    def sync_dev_entry date, duration
      sync_entry(date,
                  Timesheet::DEVELOPMENT_TASK_ID,
                  TimeEntry::DEVELOPMENT_TITLE,
                  duration,
                  dev_task_description(date))
    end

    def sync_entry date, task_id, title, duration, description = nil
      tasks = tracked_entries date

      time_entry = TimeEntry.new(
                     task_id: task_id,
                     date: date,
                     duration: duration,
                     title: title,
                     description: description
                   )

      invalid_tasks = tasks.select {|t| t.task_id == task_id && t != time_entry}

      @timesheet.delete_tasks(invalid_tasks)
      unless tasks.include?(time_entry)
        @timesheet.create_tasks [time_entry]
      end
    end

    def sync_events date, events
      return if !events || events.empty?

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

    def build_default_working_range
      dates = (Time.parse(@opts[:start_time]).to_date .. Time.parse(@opts[:end_time]).to_date).to_a
      dates = dates.select {|date| @opts[:default_working_days].include? date.strftime("%A").downcase}
      dates.map {|date| [date.to_s, []]}.to_h
    end

    def dev_task_description(date)
      tasks_delivered = @task_tracker.tasks_delivered(Date.parse(date))
      unless tasks_delivered.empty?
        ptd = []
        tasks_delivered.each do |task|
          ptd << { name: task.name, url: task.url }
        end
        { pivotal_tasks_delivered: ptd }
      else
        nil
      end
    end
  end
end
