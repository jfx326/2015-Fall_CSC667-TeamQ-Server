module WebServer
  module Response
    # Provides the base functionality for all HTTP Responses 
    # (This allows us to inherit basic functionality in derived responses
    # to handle response code specific behavior)
    class Base
      attr_reader :version, :code, :body

      def initialize(resource, options={})
        @version = DEFAULT_HTTP_VERSION #TODO: Should this be derived from resource/request
        @code = 200
        @body = resource.contents

        @resource = resource #TODO: Need to figure out how the encapsulation works with this being passed around everywhere
      end

      def to_s
        s = "#{@version} #{@code} #{RESPONSE_CODES.fetch(@code)}\r\n"

        Response.default_headers.each do |header|
          s << header[0] + ": " + header[1] + "\r\n"
        end

        s << message
      end

      def message
        msg = String.new

        case @resource.request.http_method
          when "HEAD"
            msg << "Content-Type: #{@resource.content_type}\n"
            msg << "Content-Length: #{content_length}\n"
            msg << "Connection: close\n\r\n"
          when "GET"
            msg << "Content-Type: #{@resource.content_type}\n"
            msg << "Content-Length: #{content_length}\n"
            msg << "Connection: close\n"
            msg << "\r\n"
            msg << @body
          when "PUT"
            msg << "Location: http://localhost:#{@resource.conf.port}#{@resource.request.uri}\r\n"
          when "POST"
        end

        return msg
      end

      def content_length
        @body.length
      end
    end
  end
end
