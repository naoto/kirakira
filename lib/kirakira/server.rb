require 'optparse'

module Kirakira
  class Server

    def initialize(args)
      @options = parse args
    end

    def self.run!(args)
      kirakira = self.new(args)
      kirakira.logging
      kirakira.background
    end

    def logging
      @options[:logger] = Logger.new(@options[:log], "daily")
      @options[:logger].level = @options[:debug] ? Logger::DEBUG : Logger::INFO
    end

    def background
      daemonize(@options[:debug] || @options[:foreground]) do
        Net::IRC::Server.new(@options[:host], @options[:port], Kirakira::Session, @options).start
      end
    end

    private
     def daemonize(foreground=false)
       trap("SIGINT")  { exit! 0 }
       trap("SIGTERM") { exit! 0 }
       trap("SIGHUP")  { exit! 0 }
       return yield if $DEBUG || foreground
       Process.fork do
         Process.setsid
         Dir.chdir "/"
         yield
       end
       exit! 0
     end

     def parse(args)
       opts = {
         port: 16669,
         host: "localhost",
         log: nil,
         debug: false,
         foreground: false
       }

       OptionParser.new do |parser|
         parser.instance_eval do
           self.banner = "Usage: #{$0} [opts]"
           separator = ""
           separator "Options:"
           on("-p", "--port [PORT=#{opts[:port]}]", "port number to listen") do |port|
             opts[:port] = port
           end
           on("-h", "--host [HOST=#{opts[:host]}]", "host name or IP address to listen") do |host|
             opts[:host] = host
           end
           on("-l", "--log LOG", "log file") do |log|
             opts[:log] = log
           end
           on("--debug", "Enable debug mode") do |debug|
             opts[:log]   = $stdout
             opts[:debug] = true
           end
           on("-f", "--foreground", "run foreground") do |foreground|
             opts[:log]        = $stdout
             opts[:foreground] = true
           end
           parse!(args)
         end
       end
       opts
     end

  end
end
