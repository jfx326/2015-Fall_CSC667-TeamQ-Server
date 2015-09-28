require_relative 'request'
require_relative 'response'

# This class will be executed in the context of a thread, and
# should instantiate a Request from the client (socket), perform
# any logging, and issue the Response to the client.
module WebServer
  class Worker
    # Takes a reference to the client socket and the logger object
    def initialize(client_socket, server=nil)
      @socket = client_socket
      @server = server

      process_request
    end

    # Processes the request
    def process_request
      # log_file_path already defined at httpd_conf.conf
      log_file_path = @server.options[:httpd_conf].log_file

      #TODO: THIS NEEDS ERROR CHECKING!!
      logger = Logger.new(log_file_path)

      request = Request.new(@socket)
      resource = Resource.new(request, @server.options[:httpd_conf], @server.options[:mime_types])
      response = Response::Factory.create(resource)

      logger.log(request, response)
      @socket.write response.to_s

      @socket.close

      logger.close
    end
  end
end
