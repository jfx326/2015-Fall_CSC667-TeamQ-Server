module WebServer
  module Response
    # Class to handle 400 responses
    class BadRequest < Base
      def initialize(resource, options={})
        super(resource)
        @code = 204

        @body = "<html><body><h1>400 - Bad Request</h1></body></html>"
      end

      def to_s
        s = head
        s << "Connection: close\n"
        s << "\r\n"

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
