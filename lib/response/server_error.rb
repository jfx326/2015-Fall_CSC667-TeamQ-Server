module WebServer
  module Response
    # Class to handle 500 errors
    class ServerError < Base
      def initialize(resource, options={})
        super(resource)
        @code = 500

        @body = "<html><body><h1>500 - Internal Server Error</h1></body></html>"
      end

      def message
        msg = "Content-Type: #{content_type}\n"
        msg << "Content-Length: #{content_length}\n"
        msg << "Connection: close\n"
        msg << "\r\n"
        msg << @body
      end

      def content_type
        return "text/html"
      end

      def content_length
        return @body.length
      end
    end
  end
end
