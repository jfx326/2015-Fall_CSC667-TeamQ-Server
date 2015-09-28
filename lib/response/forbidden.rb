module WebServer
  module Response
    # Class to handle 403 responses
    class Forbidden < Base
      def initialize(resource, options={})
        super(resource)
        @code = 403

        @body = "<html><body><h1>403 - Forbidden</h1></body></html>"
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
