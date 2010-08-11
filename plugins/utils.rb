require 'htmlentities'

module Plugins
  class Utils
    class << self
      def entities
        @entities ||= HTMLEntities.new
      end
    end
  end
end
