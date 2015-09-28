module WebServer
  module Response
    # Class to handle 500 errors
    class ServerError < Base
      def initialize(resource, options={})
        super(resource)
        @code = 500

        @body = "<html><body><h1>500 - Internal Server Error</h1></body></html>"
      end

      def content_type
        return 'text/html'
      end

      def content_length
        return @body.length
      end
    end
  end
end
