module Kirakira
  class Session < Net::IRC::Server::Session

    def server_name
      "kirakira: eXtraIrcGateway"
    end

    def server_version
      Kirakira::VERSION
    end

    def initialize(*args)
      super
      @channels = Channels.new @log
      @threads = []
    end

    def on_disconnected
      @channels.each do |key, channel|
        channel.kill rescue nil
      end
    end

    def on_user(message)
      super
      @channels.each do |name, ins|
        @log.info("start... #{name}")
        post @nick, JOIN, "##{name}"
        ins.start do |mes|
          privmsg(name, "##{name}", mes)
        end
        @log.info("running #{name}")
      end
    rescue => e
      @log.error e.to_s
    end

    private
     def privmsg(nick, channel, message)
       post(nick, PRIVMSG, channel, message)
     end

  end
end
