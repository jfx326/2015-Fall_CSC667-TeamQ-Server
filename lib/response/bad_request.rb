module WebServer
  module Response
    # Class to handle 400 responses
    class BadRequest < Base
      def initialize(resource, options={})
        super(resource)
        @code = 400

        @body = "<html><body><h1>400 - Bad Request</h1></body></html>"
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
