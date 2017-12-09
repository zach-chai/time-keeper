require 'time_tracker/time_entry'

module TimeTracker
  class Timesheet
    PROJECT_ID = 12499555
    ENG_OVERHEAD_TASK_ID = 6998455
    NON_ENG_OVERHEAD_TASK_ID = 7479470

    class << self
      def timesheet
        HarvestApi::Client.instance
      end

      def fetch_events opts = {}
        fetch_tasks [ENG_OVERHEAD_TASK_ID, NON_ENG_OVERHEAD_TASK_ID], opts
      end

      def create_events events
        create_tasks ENG_OVERHEAD_TASK_ID, events
      end

      def delete_events *opts
        delete_tasks *opts
      end

      private

      def fetch_tasks task_ids, opts = {}
        opts[:start_time] ||= Time.now.beginning_of_week.iso8601
        opts[:end_time] ||= Time.now.iso8601

        res = timesheet.time_entries.all(from: opts[:start_time],
                                          to: opts[:end_time])

        time_entries = res.select {|te| task_ids.include?(te.task['id'])}
        Time.zone = 'America/Toronto'
        events = []
        time_entries.each do |event|
          events << TimeTracker::TimeEntry.build_from(event)
        end
        events
      end

      def create_tasks task_id, time_entries
        time_entries.each do |time_entry|
          payload = {
            project_id: PROJECT_ID,
            task_id: task_id,
            spent_date: time_entry.spent_date,
            hours: time_entry.hours,
            notes: time_entry.title
          }

          timesheet.time_entries.create(payload)
        end
      end

      def delete_tasks time_entries
        time_entries.each do |time_entry|
          timesheet.time_entries.delete(time_entry.id)
        end
      end
    end
  end
end

# Fetch events
# Create events
# Delete events
# Fetch r&d
# Create r&d
# Update r&D
