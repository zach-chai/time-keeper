require 'time_keeper/time_entry'

module TimeKeeper
  class Timesheet
    PROJECT_ID = 12499555
    ENG_OVERHEAD_TASK_ID = 6998455
    NON_ENG_OVERHEAD_TASK_ID = 7479470
    DEVELOPMENT_TASK_ID = 6908966
    HOLIDAY_TASK_ID = 6998451
    VACATION_TASK_ID = 6908970
    SICK_LEAVE_TASK_ID = 6998447
    ALL_TASK_IDS = [
                    ENG_OVERHEAD_TASK_ID,
                    NON_ENG_OVERHEAD_TASK_ID,
                    DEVELOPMENT_TASK_ID,
                    HOLIDAY_TASK_ID,
                    VACATION_TASK_ID,
                    SICK_LEAVE_TASK_ID
                   ].freeze

    def timesheet
      HarvestApi::Client.instance
    end

    def initialize opts = {}
      @opts = opts
    end

    def fetch_tasks *args
      filter_tasks *args
    end

    def create_tasks time_entries
      create time_entries
    end

    def delete_tasks *args
      delete *args
    end

    private

    def filter_tasks task_ids, date
      fetch.select {|te| task_ids.include?(te.task_id) && te.spent_date == date}
    end

    def fetch
      if @tasks
        return @tasks
      end
      puts "Timesheet fetching tasks via network"
      @tasks = []
      Time.zone = 'America/Toronto'
      res = timesheet.time_entries.all(from: @opts[:start_time],
                                       to: @opts[:end_time])

      res.each do |task|
        @tasks << TimeKeeper::TimeEntry.build_from(task)
      end
      @tasks
    end

    def create time_entries
      time_entries.each do |time_entry|
        if @opts[:dry_run]
          puts "Add '#{time_entry.title}' on #{time_entry.spent_date} for #{time_entry.hours} hours"
        else
          payload = {
            project_id: PROJECT_ID,
            task_id: time_entry.task_id,
            spent_date: time_entry.spent_date,
            hours: time_entry.hours,
            notes: time_entry.title_and_description
          }

          timesheet.time_entries.create(payload)
        end
      end
    end

    def delete time_entries
      time_entries.each do |time_entry|
        if @opts[:dry_run]
          puts "Remove '#{time_entry.title}' on #{time_entry.spent_date} for #{time_entry.hours} hours"
        else
          timesheet.time_entries.delete(time_entry.id)
        end
      end
    end
  end
end
