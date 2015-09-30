module WebServer
  module Response
    # Class to handle 403 responses
    class Forbidden < Base
      def initialize(resource, options={})
        super(resource)
        @code = 403

        @error_body = '<html><body><h1>403 - Forbidden</h1></body></html>'
      end
    end
  end
end
