require 'bitly'

module Plugins
  class Bitly
    class << self
      def bitly
        @bitly ||= ::Bitly.new(BITLY[:username], BITLY[:api_key])
      end

      def process(command, url)
        begin
          result = case command
          when 'shorten' then bitly.shorten(url).short_url
          when 'info' then bitly.info(url).long_url
          when 'stats'
            b = bitly.stats(url).stats
            "Clicks: #{b['clicks']}, User clicks: #{b['userClicks']}"
          else
            'Unknown command. Currently support only shorten, info and stats commands'
          end
        rescue Exception => e
          result = "Error: " + e.message
        end
        result
      end
    end
  end
end
