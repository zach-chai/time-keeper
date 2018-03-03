require 'time_keeper/time_entry'

module TimeKeeper
  class TaskTracker
    def tracker_api
      PivotalApi::Client.instance
    end

    def initialize opts = {}
      @opts = opts
    end



  end
end
