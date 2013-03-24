require 'open-uri'
require 'rss'

class Hatena < Kirakira::Channel

  FEED = "http://b.hatena.ne.jp/entrylist?sort=hot&threshold=4&mode=rss"

  def gateway
    source = open(FEED).read
    rss = nil
    begin
      rss = RSS::Parser.parse(source)
    rescue
      rss = RSS::Parser.parse(source, false)
    end
    rss.items.each do |item|
      break if !@last_time.nil? and item.dc_date <= @last_time
      yield "#{item.title} #{item.link}"
    end
    @last_time = rss.items.last.dc_date
  rescue => e
    puts e
  end

end
