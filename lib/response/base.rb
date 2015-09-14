module WebServer
  module Response
    # Provides the base functionality for all HTTP Responses 
    # (This allows us to inherit basic functionality in derived responses
    # to handle response code specific behavior)
    class Base
      attr_reader :version, :code, :body

      def initialize(resource, options={})
        @resource = resource
        @version = DEFAULT_HTTP_VERSION #TODO: Should this be derived from resource/request
        @code = 200

        if options != nil
          @body = options
        end
      end

      def to_s
        s = "#{@version} #{@code} #{RESPONSE_CODES.fetch(@code)}\r\n"

        Response.default_headers.each do |header|
          s << header[0] + ": " + header[1] + "\r\n"
        end

        if @body != nil
          s << "Content-Type: #{@resource.content_type}\n"
          s << "Content-Length: #{content_length}\n"
          s << "Connection: close\n"
          s << "\r\n"
          s << @body
        else
          s << "Connection: close\r\n"
        end
      end

      def message
      end

      def content_length
        @body.length
      end
    end
  end
end
