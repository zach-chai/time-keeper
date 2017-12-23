require 'time_keeper'

module TimeKeeper
  class Cli
    def self.start(*args)
      $stdin.sync = true if $stdin.isatty
      $stdout.sync = true if $stdout.isatty

      command = if args[0] && !args[0].include?('-')
                   args.shift.strip rescue nil
                else
                  nil
                end

      opts = {}
      if args[0] == '--dry-run'
        opts[:dry_run] = true
      end
      time_keeper = TimeKeeper::Main.new opts

      if command == 'sync'
        time_keeper.sync
      end

      puts "\nFinished\n"
      true
    end
  end
end
