module WebServer
  module Response
    # Class to handle 500 errors
    class ServerError < Base
      def initialize(resource, options={})
        super(resource)
        @error = options[:error]
        @code = 500

        @error_body = "<html><body><h1>500 - Internal Server Error</h1><h3>#{@error.message}</h3></body></html>"
      end
    end
  end
end
