module WebServer
  module Response
    # Class to handle 401 responses
    class Unauthorized < Base
      def initialize(resource, options={})
        super(resource)
        @code = 401
      end

      def message
        unless File.directory?(@resource.request.uri)
          realm = File.dirname(@resource.request.uri)
        end

        realm = realm.chomp("/").reverse.chomp("/").reverse

        msg = "WWW-Authenticate: Basic realm=\"#{realm}\""

        return msg
      end
    end
  end
end
