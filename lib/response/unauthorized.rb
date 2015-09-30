module WebServer
  module Response
    # Class to handle 401 responses
    class Unauthorized < Base
      def initialize(resource, options={})
        super(resource)
        @code = 401
      end

      def to_s
        s = head
        s << "WWW-Authenticate: Basic realm=\"#{@resource.contents}\"\r\n"

        return s
      end
    end
  end
end
