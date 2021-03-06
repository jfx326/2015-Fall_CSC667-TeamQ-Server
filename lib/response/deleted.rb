module WebServer
  module Response
    # Class to handle 204 responses
    class Deleted < Base
      def initialize(resource)
        super(resource)
        @code = 204
      end

      def message
        return "Connection: #{@resource.conf.timeout ? 'keep-alive' : 'close'}\n\r\n"
      end
    end
  end
end
