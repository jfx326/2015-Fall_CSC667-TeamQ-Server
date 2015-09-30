module WebServer
  module Response
    # Class to handle 400 responses
    class BadRequest < Base
      def initialize(resource=nil, options={})
        super(resource)
        @code = 400

        @error_body = '<html><body><h1>400 - Bad Request</h1></body></html>'
      end
    end
  end
end
