module WebServer
  module Response
    # Class to handle 201 responses
    class SuccessfullyCreated < Base
      def initialize(resource, options={})
        super(resource)
        @code = 201
      end

      def message
        msg = "Connection: #{@resource.conf.timeout ? 'keep-alive' : 'close'}\n"
        msg << "\r\n"

        return msg
      end
    end
  end
end
