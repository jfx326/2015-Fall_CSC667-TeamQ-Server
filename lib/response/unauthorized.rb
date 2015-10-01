module WebServer
  module Response
    # Class to handle 401 responses
    class Unauthorized < Base
      def initialize(resource)
        super(resource)
        @code = 401
      end

      def message
        return "WWW-Authenticate: Basic realm=\"#{@resource.contents}\"\n\r\n"
      end

      def content_length
        0
      end
    end
  end
end
