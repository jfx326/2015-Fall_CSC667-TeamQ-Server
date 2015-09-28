module WebServer
  module Response
    # Class to handle 204 responses
    class Deleted < Base
      def initialize(resource, options={})
        super(resource)
        @code = 204
      end

      def message
        "Connection: close\n\r\n"
      end
    end
  end
end
