module Kiba
  class Control
    def pre_processes
      @pre_processes ||= []
    end

    def sources
      @sources ||= []
    end
    
    def ctransforms
      @ctransforms ||= []
    end

    def transforms
      @transforms ||= []
    end

    def destinations
      @destinations ||= []
    end

    def post_processes
      @post_processes ||= []
    end
  end
end
