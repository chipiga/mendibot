require 'twitter'

module Mendibot
  module Plugins
    class Twitter
      class << self
        def twitter
          @twitter ||= ::Twitter::Base.new(::Twitter::HTTPAuth.new(TWITTER[:email], TWITTER[:password]))
        end

        def process(command, arg)
          case command
          when 'status' # Get user status and try translate it to english
            begin
              result = ::Twitter.user(arg).status.text
              from = Mendibot::Plugins::Translate.translator.detect_language(result)['language']
              to = 'en'
              result = Mendibot::Plugins::Utils.entities.decode(Mendibot::Plugins::Translate.translator.translate(from.to_sym, to.to_sym, result)) unless from == to
              # result = Mendibot::Plugins::Translate.process('en', ::Twitter.user(arg).status.text)
            rescue Exception => e
              result = "Error: " + e.message unless e.class.to_s.include?('Google::Translator') # Ignore translation errors
            end
          when 'update' # Update user status, automatically short URLs through bit.ly
            begin
              URI.extract(arg, "http").each{|url| arg.sub!(url, Mendibot::Plugins::Bitly.process('shorten', url))}
              t = twitter.update(arg)
              result = "http://twitter.com/#{t.user.screen_name}/status/#{t.id}"
            rescue Exception => e
              result = "Error: " + e.message
            end
          else
            result = 'Unknown command. Currently support only status and update commands'
          end
          result
        end
      end
    end
  end
end
