module WebServer
  module Response
    # Class to handle 404 errors
    class NotFound < Base
      def initialize(resource, options={})
        super(resource)
        @code = 404

        @body = "<html><body><h1>404 - Resource Not Found</h1></body></html>"
      end
      
      def to_s
        s = head
        s << message

        return s
      end

      def message
        msg = "Content-Type: text/html\n"
        msg << "Content-Length: #{content_length}\n"
        msg << "Connection: close\n"
        msg << "\r\n"
        msg << @body
      end

      def content_length
        return @body.length
      end
    end
  end
end
