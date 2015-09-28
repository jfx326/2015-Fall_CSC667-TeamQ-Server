module WebServer
  module Response
    # Class to handle 201 responses
    class SuccessfullyCreated < Base
      def initialize(resource, options={})
        super(resource)
        @code = 201
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
