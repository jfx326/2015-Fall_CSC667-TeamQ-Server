require_relative 'response/base'

module WebServer
  module Response
    DEFAULT_HTTP_VERSION = 'HTTP/1.1'

    RESPONSE_CODES = {
      200 => 'OK',
      201 => 'Created',
      204 => 'No Content',
      304 => 'Not Modified',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      500 => 'Internal Server Error'
    }.freeze

    def self.default_headers
      {
        'Date' => Time.now.strftime('%a, %e %b %Y %H:%M:%S %Z'),
        'Server' => 'John Roberts CSC 667'
      }
    end

    module Factory

      def self.create(resource)
        case resource.process
          when 200
            Response::Base.new(resource)
          when 201
            Response::SuccessfullyCreated.new(resource)
          when 204
            Response::Deleted.new(resource)
          when 304
            Response::NotModified.new(resource)
          when 400
            Response::BadRequest.new(resource)
          when 401
            Response::Unauthorized.new(resource)
          when 403
            Response::Forbidden.new(resource)
          when 404
            Response::NotFound.new(resource)
          else
            Response::ServerError.new(resource)
        end
      end

      def self.error(resource, error_object)
        Response::ServerError.new(resource, exception: error_object)
      end
    end
  end
end
