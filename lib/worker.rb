require_relative 'request'
require_relative 'response'
require_relative 'logger'

module WebServer
  class Worker
    # Takes a reference to the client socket and the logger object
    def initialize(client_socket, server=nil)
      @socket, @server = client_socket, server

      setup_log
      process_request(@socket)
      close_request
    end

    def setup_log
      log_file_path = @server.options[:httpd_conf].log_file

      @logger = Logger.new(log_file_path)
    end

    def process_request(socket)
      #TODO: THIS NEEDS ERROR CHECKING!!

      request = Request.new(socket)
      resource = Resource.new(request, @server.options[:httpd_conf], @server.options[:mime_types])
      response = Response::Factory.create(resource)

      @logger.log(request, response)
      socket.write response.to_s
    end

    def close_request
      @socket.close

      @logger.close
    end
  end
end
