module Kirakira
  class Channels < Hash

    def initialize(logger)
      @logger = logger
      load do |channel|
        @logger.info("loading... #{channel}")
        self[channel] = Channels.const_get(channel).new @logger
      end
    end

    private
     def load
       Dir::entries('channels').each do |channel|
         next if File.directory?("channels/#{channel}")
         require "#{channel}"
         yield convert_class_name(channel)
       end
     end

     def convert_class_name(filename)
       name = File.basename(filename, '.rb')
       name.split(/_/).map! { |words|
         words_char = words.split(//)
         words[0] = words_char.first.upcase
         words
       }.join
     end

  end
end
