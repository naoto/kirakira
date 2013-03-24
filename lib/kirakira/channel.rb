module Kirakira
  class Channel

    def initialize(logger)
      @interval = 300
      @logger = logger
    end

    def start(&blk)
      @thread = Thread.start do
        loop do
          Array(gateway(&blk)).each do |msg|
            blk.call msg
          end
          sleep @interval
        end
      end
    rescue => e
      puts e
    end

    def kill
      @thread.kill rescue nil
    end

    def gateway
    end

  end
end
