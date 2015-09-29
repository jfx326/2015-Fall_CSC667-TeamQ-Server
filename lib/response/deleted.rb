module WebServer
  module Response
    # Class to handle 204 responses
    class Deleted < Base
      def initialize(resource, options={})
        super(resource)
        @code = 204
      end
    end
  end
end
