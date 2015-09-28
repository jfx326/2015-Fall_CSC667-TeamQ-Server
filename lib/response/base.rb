module WebServer
  module Response
    # Provides the base functionality for all HTTP Responses 
    # (This allows us to inherit basic functionality in derived responses
    # to handle response code specific behavior)
    class Base
      attr_reader :version, :code

      def initialize(resource, options={})
        @version = DEFAULT_HTTP_VERSION #TODO: Should this be derived from resource/request
        @code = 200

        @resource = resource #TODO: Need to figure out how the encapsulation works with this being passed around everywhere
      end

      def head
        head = "#{@version} #{@code} #{RESPONSE_CODES.fetch(@code)}\n"

        Response.default_headers.each do |header|
          head << header[0] + ": " + header[1] + "\n"
        end

        return head
      end

      def to_s
        s = head
        s << message

        return s
      end

      def message
        return @resource.script ? script_message : default_message
      end

      def default_message
        msg = "Content-Type: #{content_type}\n"
        msg << "Content-Length: #{content_length}\n"
        msg << "Connection: close\n"
        msg << "\r\n"
        msg << (@resource.contents || @body)

        return msg
      end

      def script_message
        msg = String.new

        #TODO: Not sure if this is valid
        if @resource.contents.include? 'Content-Type:'
          msg << @resource.contents
        else
          msg << "Content-Type: text/html\n"
          msg << "\r\n"
          msg << @resource.contents
        end

        return msg
      end

      def put_message
        #TODO: I think this needs a resource.contents as well??"
        msg = "Location: http://localhost:#{@resource.conf.port}#{@resource.request.uri}\r\n"
      end

      def content_type
        return @resource.content_type
      end

      def content_length
        return @resource.contents ? @resource.contents.length : 0
      end
    end
  end
end
