module WebServer
  module Response
    # Class to handle 403 responses
    class Forbidden < Base
      def initialize(resource, options={})
        super(resource)
        @code = 403
      end

      def message
        return ''
      end
    end
  end
end
