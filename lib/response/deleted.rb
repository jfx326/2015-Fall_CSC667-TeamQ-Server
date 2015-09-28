module WebServer
  module Response
    # Class to handle 204 responses
    class Deleted < Base
      def initialize(resource, options={})
        super(resource)
        @code = 204
      end

      def to_s
        s = head
        s << "Connection: close\n"
        s << "\r\n"

        return s
      end
    end
  end
end
