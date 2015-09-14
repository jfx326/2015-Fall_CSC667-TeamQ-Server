module WebServer
  module Response
    # Class to handle 404 errors
    class NotFound < Base
      def initialize(resource, options={})
        super(resource)
        @code = 404
        @body = "<html><body><h1>404 - Resource Not Found</h1></body></html>\r\n"
      end
    end
  end
end
