require 'google_translate' # gem google-translate

module Plugins
  class Translate
    class << self
      def translator
        @translator ||= ::Google::Translator.new
      end

      def process(lang, text)
        begin
          if lang.include?('|')
            from = lang.split('|').first
            to = lang.split('|').last
          else
            from = translator.detect_language(text)['language']
            to = lang
          end
          result = from == to ? text : Plugins::Utils.entities.decode(translator.translate(from.to_sym, to.to_sym, text))
        rescue Exception => e
          result = "Error: " + e.message
        end
        result
      end
    end
  end
end
